# Scripts PowerShell (passos manuais da semana 0)

São os comandos do guia da semana 0 em forma de script, para os poderes repetir quando refizeres uma máquina. Corre-os numa consola do PowerShell **como administrador**, dentro da máquina virtual.

| Script | Onde | O que faz |
| --- | --- | --- |
| `01-rede-e-nome.ps1` | DC01 e WS01 | Muda o nome e fixa o endereço de rede (o que o SConfig faz nas opções 2 e 8) |
| `02-instalar-ad.ps1` | DC01 | Instala o Active Directory e cria o domínio `ribeira.test`; reinicia no fim |
| `03-depois-do-dominio.ps1` | DC01 | Confirma o domínio, acerta o DNS e mede a velocidade do `Get-ADUser` |
| `04-instalar-adcs.ps1` | DC01 | Instala a autoridade de certificação (bónus) |
| `05-juntar-ao-dominio.ps1` | WS01 | Aponta o DNS ao DC01 e junta o computador ao domínio |
| `06-preparar-ansible.ps1` | DC01 e WS01 | Ativa o WinRM para o Ansible, a partir do Mac |

Ordem típica: `01` (DC01) → `02` → `03` → `04` (opcional) → `01` (WS01) → `05` → `06` (nas duas).

## Como os levar para dentro da máquina virtual

O DC01 está em modo Core, sem ambiente gráfico: abre o PowerShell com `powershell` na linha de comandos. As máquinas têm internet, por isso o mais simples é descarregar os scripts lá de dentro (o `-UseBasicParsing` é obrigatório no modo Core). Não testei estas transferências.

```powershell
# Opção A: depois de o repositório estar público no GitHub (troca o nome de utilizador)
Invoke-WebRequest -UseBasicParsing -OutFile 01-rede-e-nome.ps1 `
    https://raw.githubusercontent.com/lucasbaccoistec/ribeira-purple-lab/main/lab/scripts/01-rede-e-nome.ps1

# Opção B: a partir do Mac. Na pasta lab/scripts corre "python3 -m http.server 8000";
# na rede partilhada do UTM o Mac costuma ser o endereço .1 (confirma no gateway do ipconfig).
Invoke-WebRequest -UseBasicParsing -OutFile 01-rede-e-nome.ps1 http://192.168.64.1:8000/01-rede-e-nome.ps1
```

Descarrega todos os scripts de que precisas antes de correres o `01`, porque esse muda o endereço de rede. Se o Windows recusar correr scripts, só para esta sessão:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

## Notas

- Estes scripts foram escritos a partir dos comandos do guia e só a **sintaxe** foi verificada (não foram executados numa máquina Windows). Se algum falhar, regista o erro no `docs/week-0-log.md` e corrige o script.
- Os ficheiros estão em UTF-8 com BOM para o Windows PowerShell 5.1 mostrar bem os acentos. Se os editares, guarda-os na mesma codificação.
- Servem só para o laboratório. Não os uses em máquinas reais.
