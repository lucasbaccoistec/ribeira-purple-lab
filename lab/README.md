# Laboratório como código

O laboratório monta-se em duas camadas:

1. **À mão, uma vez:** instalar o sistema em cada máquina virtual e dar-lhe nome e endereço (scripts em [`scripts/`](scripts/README.md), a partir do guia da semana 0).
2. **Com Ansible, as vezes que quiseres:** o resto (auditorias, domínio, certificados, utilizadores, grupos) corre a partir do Mac e pode repetir-se sem estragar nada.

```text
lab/
  scripts/   scripts PowerShell que fazem os passos manuais da semana 0 (DC01 e WS01)
  ansible/   playbook site.yml, variáveis, inventário de exemplo e uma role por tema
```

## Pré-requisitos

- Semana 0 concluída: DC01 com o domínio `ribeira.test`, WS01 no domínio e Kali a funcionar (ver [`../docs/week-0-log.md`](../docs/week-0-log.md)).
- No Mac: `make setup` (cria o ambiente Python e instala o Ansible e as coleções).
- Em cada máquina Windows: o WinRM ativo (`scripts/06-preparar-ansible.ps1`).

## Primeira execução

```bash
cd lab/ansible
cp inventory.example.yml inventory.yml     # ajusta os endereços IP ao teu UTM
export RIBEIRA_LAB_PASSWORD='...'          # palavra-passe do Administrator (mínimo 12 caracteres)
export RIBEIRA_DSRM_PASSWORD='...'         # palavra-passe do modo de restauro (mínimo 12 caracteres)
export RIBEIRA_USER_PASSWORD='...'         # palavra-passe dos funcionários, diferente da do Administrator

../../.venv/bin/ansible windows -m ansible.windows.win_ping   # as duas máquinas respondem "pong"?
../../.venv/bin/ansible-playbook site.yml --check --diff       # ensaio: mostra o que mudaria
../../.venv/bin/ansible-playbook site.yml                      # aplica
```

Notas:

- A palavra-passe do Administrator local do DC01 tem de ser igual a `RIBEIRA_LAB_PASSWORD`: depois de o servidor virar controlador de domínio, essa conta passa a ser a do domínio.
- O Ansible corre em etapas com tags: `--tags common`, `domain`, `adcs`, `objects`, `workstation`. Põe `ribeira_install_adcs: false` em `group_vars/all.yml` para saltar a autoridade de certificação.
- Se o ensaio com `--check` falhar em tarefas que dependem de outras (por exemplo, utilizadores antes de o domínio existir), é normal: o modo de ensaio não executa as dependências.

## Estado de validação

| O que | Verificado |
| --- | --- |
| Sintaxe do playbook e das roles (`make lab-syntax`) | Sim |
| Parâmetros de cada tarefa contra a documentação dos módulos | Sim |
| Estilo YAML (`make lint`) | Sim |
| Execução real contra o DC01 e o WS01 | **Ainda não**: confirma na primeira execução e corrige o que for preciso |
| Scripts PowerShell | Só a sintaxe; a execução real faz-se na semana 0 |

## Palavras-passe

Nunca ficam no Git. O Ansible lê-as de variáveis de ambiente (`RIBEIRA_LAB_PASSWORD`, `RIBEIRA_DSRM_PASSWORD`, `RIBEIRA_USER_PASSWORD`); o ficheiro `inventory.yml` está no `.gitignore`. A dos funcionários tem de ser diferente da do Administrator: o cenário começa com um funcionário sem privilégios, e o playbook recusa correr se as duas forem iguais. Usa palavras-passe de laboratório que não uses em mais lado nenhum.
