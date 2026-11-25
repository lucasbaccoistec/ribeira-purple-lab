# Ribeira Purple Lab: comandos do dia a dia. Corre "make help" para ver a lista.
SHELL := /bin/bash
.DEFAULT_GOAL := help

PYTHON ?= python3
# O validador Sigma descarrega a lista de técnicas do MITRE ATT&CK na primeira vez (fica em cache).
# Não usamos tags D3FEND, por isso saltamos essa validação para não depender de mais um site externo.
SIGMA_FLAGS ?= -x d3_fendtag
VENV   := .venv
# Usa o ambiente virtual (.venv) se já existir; senão usa o que estiver no PATH
# (é o caso do GitHub Actions).
BIN    := $(if $(wildcard $(CURDIR)/$(VENV)/bin/python3),$(CURDIR)/$(VENV)/bin/,)

.PHONY: help setup tools lint lab-syntax sigma-check test-detections check report clean

help: ## Mostra esta lista de comandos
	@grep -hE '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "} {printf "  %-16s %s\n", $$1, $$2}'

setup: ## Cria o ambiente Python (.venv) e instala o Ansible e as ferramentas de teste
	@$(PYTHON) -c 'import sys; sys.exit(sys.version_info < (3, 11))' || { echo "Precisas de Python 3.11 ou mais recente. No Mac: brew install python@3.13 e depois make setup PYTHON=python3.13"; exit 1; }
	$(PYTHON) -m venv $(VENV)
	$(VENV)/bin/pip install --upgrade pip
	$(VENV)/bin/pip install -r requirements.txt
	$(VENV)/bin/ansible-galaxy collection install -r lab/ansible/requirements.yml -p lab/ansible/collections

tools: ## Descarrega o Chainsaw (versão fixa, com verificação SHA-256)
	bash detections/tests/get-chainsaw.sh

lint: ## Verifica o estilo de todos os ficheiros YAML
	$(BIN)yamllint .

lab-syntax: ## Verifica a sintaxe do playbook Ansible (não toca em nenhuma máquina)
	cd lab/ansible && $(BIN)ansible-playbook -i inventory.example.yml site.yml --syntax-check

sigma-check: ## Valida as regras Sigma (sintaxe e boas práticas)
	$(BIN)sigma check -i $(SIGMA_FLAGS) detections/sigma

test-detections: ## Testa as regras contra eventos reais (.evtx) com o Chainsaw
	$(BIN)python3 detections/tests/run_tests.py

check: tools lint lab-syntax sigma-check test-detections ## Corre todas as verificações

report: ## Gera o PDF do relatório a partir de report/relatorio.md (precisa de: brew install pandoc typst)
	@test -f report/relatorio.md || { echo "Cria primeiro o relatório: cp report/template.md report/relatorio.md"; exit 1; }
	@command -v pandoc >/dev/null || { echo "Falta o pandoc: brew install pandoc typst"; exit 1; }
	@command -v typst >/dev/null || { echo "Falta o typst: brew install typst"; exit 1; }
	mkdir -p report/build
	pandoc report/relatorio.md -o report/build/relatorio.pdf --pdf-engine=typst -V mainfont="Libertinus Serif"

clean: ## Apaga ficheiros gerados (o .venv e o .tools ficam)
	rm -rf report/build detections/tests/.generated-mapping.yml
