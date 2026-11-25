# Deteção como código

Aqui vivem as regras que **apanham** cada passo do ataque, escritas em [Sigma](https://sigmahq.io) (um formato aberto e independente de produto) e testadas automaticamente contra eventos reais exportados do laboratório.

```text
detections/
  sigma/        as regras (uma por ficheiro); _template.yml é o modelo
  samples/evtx/ eventos reais do laboratório usados nos testes
  tests/        cases.yml (o que testar), run_tests.py, get-chainsaw.sh, extra-fields.txt
```

## Como escrever uma regra, passo a passo

1. **Faz o passo do ataque** no laboratório e documenta-o em `attack/`.
2. **Exporta os eventos** dessa janela de tempo (instruções em [`samples/evtx/README.md`](samples/evtx/README.md)). Exporta também uma janela de atividade normal.
3. **Copia o modelo** `sigma/_template.yml` para um nome novo, gera um `id` novo e escreve a deteção.
4. **Regista os casos** em `tests/cases.yml`: um `match` com a amostra do ataque e um `no-match` com a atividade normal.
5. **Corre** `make check`. Se passar, a regra apanha o ataque e não dispara com o tráfego normal.
6. **Atualiza o mapa de cobertura**: acrescenta a técnica a `docs/attack-navigator-layer.json` (ver abaixo).

## O que o `make check` verifica

| Verificação | O que apanha |
| --- | --- |
| `sigma check -i` | regra mal formada, `id` repetido ou inválido, tags erradas |
| casos obrigatórios | regra sem nenhum teste `match` |
| campos conhecidos | regra que usa um campo que o Chainsaw não conhece (nunca dispararia) |
| Chainsaw nas amostras | regra que não dispara no ataque, ou que dispara no tráfego normal |

## Se o Chainsaw não reconhece um campo

O Chainsaw só compara os campos listados no seu ficheiro de mapeamento. Se a tua regra usar outro (por exemplo `CertificateTemplate`), o `run_tests.py` avisa com o nome do campo. Acrescenta esse nome a [`tests/extra-fields.txt`](tests/extra-fields.txt), uma linha por campo, tal como aparece em `EventData` no Visualizador de Eventos.

## Mapa de cobertura (ATT&CK Navigator)

`docs/attack-navigator-layer.json` é uma camada do [ATT&CK Navigator](https://mitre-attack.github.io/attack-navigator/) que mostra que técnicas já têm regra testada. Abre o Navigator, escolhe **Open Existing Layer**, **Upload from local** e carrega o ficheiro. Para marcar uma técnica como coberta, acrescenta à lista `techniques` do ficheiro um bloco como este, com o identificador da técnica e a pontuação 100:

```json
{ "techniqueID": "T1098", "score": 100, "comment": "grupo_privilegiado_alterado.yml" }
```

Só marques como coberta uma técnica depois de o `make check` passar com os casos `match` e `no-match`.

## Licenças

O Chainsaw (GPL-3.0) e o respetivo ficheiro de mapeamento **não** estão neste repositório: o `make tools` descarrega-os para `.tools/` (que o Git ignora), com verificação do SHA-256.
