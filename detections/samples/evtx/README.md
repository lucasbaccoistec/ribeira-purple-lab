# Amostras de eventos (.evtx)

Aqui ficam os eventos do **teu laboratório** que servem de prova para os testes das regras. Cada regra deve ter, pelo menos:

- uma amostra **com** o comportamento a detetar (o teste `match`);
- uma amostra de **atividade normal** (o teste `no-match`), para provar que a regra não dispara por tudo e por nada.

Organiza por tema, uma pasta por técnica, por exemplo `kerberos/`, `certificados/`, `grupos/`.

## Como exportar uma amostra

Numa linha de comandos de administrador, na máquina onde o evento aconteceu (DC01 ou WS01), exporta só a janela de tempo que interessa. Isto mantém o ficheiro pequeno e evita levar dados que não precisas.

```powershell
# A pasta C:\Temp não existe numa instalação nova do Windows: cria-a primeiro.
New-Item -ItemType Directory -Force C:\Temp | Out-Null
# Substitui as datas (UTC) pela janela do teu teste e o nome do ficheiro.
wevtutil epl Security C:\Temp\amostra.evtx /q:"*[System[TimeCreated[@SystemTime>='2026-12-01T10:00:00Z' and @SystemTime<='2026-12-01T10:15:00Z']]]"
```

Para eventos do Sysmon, troca `Security` por `Microsoft-Windows-Sysmon/Operational`.

Depois traz o ficheiro para o Mac com o Ansible, que já fala com as duas máquinas por WinRM. A pasta partilhada do UTM não serve para o DC01: precisa das ferramentas do UTM (SPICE), que o DC01 não tem. No Mac, a partir de `lab/ansible` e com as variáveis das palavras-passe definidas (ver [`lab/README.md`](../../../lab/README.md)):

```bash
# Troca DC01 por WS01 se a amostra vier do posto de trabalho, e kerberos pelo tema.
# Escreve o caminho do Windows com /: num comando destes, "\a" vira um carácter especial.
../../.venv/bin/ansible DC01 -m ansible.builtin.fetch -a "src=C:/Temp/amostra.evtx dest=../../detections/samples/evtx/kerberos/ flat=yes"
```

## Cuidados

- Só exportes eventos do laboratório. Nunca de máquinas reais, de casa ou do trabalho.
- Confirma que o ficheiro não tem palavras-passe nem dados pessoais teus (os nomes de utilizador do laboratório não são um problema).
- As amostras públicas de outros autores (por exemplo o repositório EVTX-ATTACK-SAMPLES) têm a sua própria licença: não as copies para aqui. Para estudar, descarrega-as à parte.
- Ficheiros com mais de 5 MB devem ficar de fora do Git. Reduz a janela de tempo e volta a exportar.
