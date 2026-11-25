#!/usr/bin/env python3
"""Testa as regras Sigma do projeto contra eventos reais (.evtx) com o Chainsaw.

Cada caso em detections/tests/cases.yml liga uma regra a uma amostra de eventos:
  expect: match      a regra TEM de disparar (apanha o ataque)
  expect: no-match   a regra NÃO pode disparar (apanha falsos positivos)

O teste falha se:
  - alguma regra em detections/sigma/ não tiver pelo menos um caso "match";
  - um caso apontar para uma regra ou amostra que não existe;
  - uma regra usar um campo que o Chainsaw não conhece (senão nunca dispararia,
    e um teste "no-match" passaria sem testar nada);
  - o resultado de um caso não for o esperado.

Uso:
  python3 detections/tests/run_tests.py          # corre todos os casos
  python3 detections/tests/run_tests.py --list   # lista regras e casos, sem correr nada

Variáveis de ambiente opcionais:
  CHAINSAW          caminho do executável do Chainsaw
  CHAINSAW_MAPPING  caminho do mapeamento oficial (sigma-event-logs-all.yml)
"""
from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[2]
RULES_DIR = ROOT / "detections" / "sigma"
TESTS_DIR = ROOT / "detections" / "tests"
CASES_FILE = TESTS_DIR / "cases.yml"
EXTRA_FIELDS_FILE = TESTS_DIR / "extra-fields.txt"
GENERATED_MAPPING = TESTS_DIR / ".generated-mapping.yml"
LOCAL_CHAINSAW = ROOT / ".tools" / "chainsaw"

CASE_KEYS = {"rule", "sample", "expect", "min_hits", "name"}
NON_FIELD_KEYS = {"condition", "timeframe"}


@dataclass
class Rule:
    path: Path
    rule_id: str
    title: str
    fields: set[str]


@dataclass
class Case:
    index: int
    rule: Path
    sample: Path
    expect: str
    min_hits: int
    name: str


def rel(path: Path) -> str:
    try:
        return str(path.resolve().relative_to(ROOT))
    except ValueError:
        return str(path)


def detection_fields(detection: dict) -> set[str]:
    """Nomes de campos usados nas seleções de uma regra (sem modificadores como |contains)."""
    fields: set[str] = set()
    for key, value in detection.items():
        if key in NON_FIELD_KEYS:
            continue
        blocks = value if isinstance(value, list) else [value]
        for block in blocks:
            if isinstance(block, dict):
                for field_key in block:
                    name = str(field_key).split("|")[0]
                    if name:
                        fields.add(name)
    return fields


def load_rules(errors: list[str]) -> dict[Path, Rule]:
    rules: dict[Path, Rule] = {}
    if not RULES_DIR.is_dir():
        return rules
    for path in sorted(list(RULES_DIR.rglob("*.yml")) + list(RULES_DIR.rglob("*.yaml"))):
        if path.name.startswith("_"):
            continue
        try:
            data = yaml.safe_load(path.read_text(encoding="utf-8"))
        except yaml.YAMLError as exc:
            errors.append(f"{rel(path)}: YAML inválido ({exc})")
            continue
        if not isinstance(data, dict) or "detection" not in data:
            errors.append(f"{rel(path)}: não parece uma regra Sigma (falta 'detection')")
            continue
        rule_id, title = data.get("id"), data.get("title")
        if not rule_id or not title:
            errors.append(f"{rel(path)}: a regra precisa de 'id' e 'title'")
            continue
        rules[path.resolve()] = Rule(
            path=path.resolve(),
            rule_id=str(rule_id),
            title=str(title),
            fields=detection_fields(data["detection"]),
        )
    return rules


def resolve_rule(value: str, rules: dict[Path, Rule]) -> Path | None:
    for candidate in (ROOT / value, RULES_DIR / value):
        if candidate.resolve() in rules:
            return candidate.resolve()
    return None


def load_cases(rules: dict[Path, Rule], errors: list[str]) -> list[Case]:
    if not CASES_FILE.is_file():
        errors.append(f"Falta {rel(CASES_FILE)}")
        return []
    data = yaml.safe_load(CASES_FILE.read_text(encoding="utf-8")) or {}
    raw_cases = data.get("cases") or []
    cases: list[Case] = []
    for index, raw in enumerate(raw_cases, start=1):
        where = f"caso {index}"
        if not isinstance(raw, dict):
            errors.append(f"{where}: tem de ser um bloco com rule, sample e expect")
            continue
        unknown = set(raw) - CASE_KEYS
        if unknown:
            errors.append(f"{where}: chaves desconhecidas: {', '.join(sorted(unknown))}")
            continue
        expect = raw.get("expect")
        if expect not in ("match", "no-match"):
            errors.append(f"{where}: 'expect' tem de ser match ou no-match")
            continue
        rule_path = resolve_rule(str(raw.get("rule", "")), rules)
        if rule_path is None:
            errors.append(f"{where}: regra '{raw.get('rule')}' não encontrada em detections/sigma/")
            continue
        sample = (ROOT / str(raw.get("sample", ""))).resolve()
        if not sample.exists():
            errors.append(f"{where}: amostra '{raw.get('sample')}' não existe")
            continue
        min_hits = int(raw.get("min_hits", 1))
        name = str(raw.get("name") or f"{rules[rule_path].title} / {rel(sample)}")
        cases.append(Case(index, rule_path, sample, expect, min_hits, name))
    return cases


def find_chainsaw() -> Path:
    env = os.environ.get("CHAINSAW")
    candidates = [Path(env)] if env else []
    candidates.append(LOCAL_CHAINSAW / "chainsaw")
    on_path = shutil.which("chainsaw")
    if on_path:
        candidates.append(Path(on_path))
    for candidate in candidates:
        if candidate.is_file() and os.access(candidate, os.X_OK):
            return candidate
    sys.exit("Não encontrei o Chainsaw. Corre 'make tools' (ou define CHAINSAW=/caminho/chainsaw).")


def find_stock_mapping(chainsaw: Path) -> Path:
    env = os.environ.get("CHAINSAW_MAPPING")
    candidates = [Path(env)] if env else []
    candidates.append(chainsaw.resolve().parent / "mappings" / "sigma-event-logs-all.yml")
    for candidate in candidates:
        if candidate.is_file():
            return candidate
    sys.exit("Não encontrei o mapeamento do Chainsaw (sigma-event-logs-all.yml). Define CHAINSAW_MAPPING.")


def read_extra_fields() -> list[str]:
    if not EXTRA_FIELDS_FILE.is_file():
        return []
    fields = []
    for line in EXTRA_FIELDS_FILE.read_text(encoding="utf-8").splitlines():
        line = line.split("#", 1)[0].strip()
        if line:
            fields.append(line)
    return fields


def build_mapping(stock: Path, extra_fields: list[str]) -> set[str]:
    """Escreve o mapeamento gerado (oficial + campos extra) e devolve os campos conhecidos."""
    mapping = yaml.safe_load(stock.read_text(encoding="utf-8"))
    known: set[str] = set()
    for group in mapping["groups"]:
        present = {field["from"] for field in group["fields"]}
        for name in extra_fields:
            if name not in present:
                group["fields"].append(
                    {"from": name, "to": f"Event.EventData.{name}", "visible": False}
                )
        known |= {field["from"] for field in group["fields"]}
    GENERATED_MAPPING.write_text(
        yaml.safe_dump(mapping, sort_keys=False, allow_unicode=True), encoding="utf-8"
    )
    return known


def run_case(case: Case, rule: Rule, chainsaw: Path) -> tuple[int | None, str]:
    """Corre o Chainsaw só com a regra do caso. Devolve (disparos, erro)."""
    with tempfile.TemporaryDirectory() as tmp:
        rule_copy = Path(tmp) / case.rule.name
        shutil.copyfile(case.rule, rule_copy)
        command = [
            str(chainsaw), "hunt", str(case.sample),
            "-s", str(rule_copy),
            "--mapping", str(GENERATED_MAPPING),
            "--json", "-q",
        ]
        try:
            result = subprocess.run(command, capture_output=True, text=True, timeout=600)
        except subprocess.TimeoutExpired:
            return None, "o Chainsaw demorou mais de 10 minutos"
    if result.returncode != 0:
        detail = (result.stderr or result.stdout).strip()[:300]
        hint = detail or "sem mensagem; confirma que a amostra é um .evtx válido ou uma pasta com .evtx"
        return None, f"o Chainsaw terminou com erro {result.returncode} ({hint})"
    output = result.stdout.strip()
    if not output:
        return 0, ""
    try:
        detections = json.loads(output)
    except json.JSONDecodeError as exc:
        return None, f"resposta do Chainsaw ilegível ({exc})"
    hits = sum(1 for item in detections if item.get("id") == rule.rule_id)
    return hits, ""


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("--list", action="store_true", help="lista regras e casos sem correr o Chainsaw")
    args = parser.parse_args()

    errors: list[str] = []
    rules = load_rules(errors)
    cases = load_cases(rules, errors)

    if args.list:
        print(f"Regras ({len(rules)}):")
        for rule in rules.values():
            print(f"  - {rel(rule.path)}  [{rule.title}]")
        print(f"Casos ({len(cases)}):")
        for case in cases:
            print(f"  - {case.expect:8} {case.name}")
        for error in errors:
            print(f"  ! {error}")
        return 1 if errors else 0

    for rule in rules.values():
        positives = [c for c in cases if c.rule == rule.path and c.expect == "match"]
        negatives = [c for c in cases if c.rule == rule.path and c.expect == "no-match"]
        if not positives:
            errors.append(f"{rel(rule.path)}: sem nenhum caso 'match' em cases.yml (toda a regra tem de ser testada)")
        elif not negatives:
            print(f"AVISO  {rel(rule.path)}: sem caso 'no-match' (recomendado para apanhar falsos positivos)")

    if not rules and not cases and not errors:
        print("Ainda não há regras em detections/sigma/ nem casos em cases.yml: nada a testar.")
        return 0
    if errors:
        for error in errors:
            print(f"ERRO   {error}")
        return 1

    chainsaw = find_chainsaw()
    known_fields = build_mapping(find_stock_mapping(chainsaw), read_extra_fields())

    unknown_found = False
    for rule in rules.values():
        missing = sorted(rule.fields - known_fields)
        if missing:
            unknown_found = True
            print(
                f"ERRO   {rel(rule.path)}: campos desconhecidos para o Chainsaw: {', '.join(missing)}. "
                f"Acrescenta-os a {rel(EXTRA_FIELDS_FILE)}."
            )
    if unknown_found:
        return 1

    failures = 0
    for case in cases:
        rule = rules[case.rule]
        hits, error = run_case(case, rule, chainsaw)
        if error:
            failures += 1
            print(f"ERRO   {case.name}: {error}")
        elif case.expect == "match" and hits >= case.min_hits:
            print(f"OK     {case.name} ({hits} disparos)")
        elif case.expect == "no-match" and hits == 0:
            print(f"OK     {case.name} (0 disparos, como esperado)")
        else:
            failures += 1
            wanted = f">= {case.min_hits}" if case.expect == "match" else "0"
            print(f"FALHOU {case.name}: {hits} disparos, esperava {wanted}")

    total = len(cases)
    print(f"\n{total - failures}/{total} casos passaram.")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
