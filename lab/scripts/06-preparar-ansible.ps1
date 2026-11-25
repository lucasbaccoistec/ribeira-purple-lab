#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Prepara esta máquina para ser configurada pelo Ansible a partir do Mac (WinRM).

.DESCRIPTION
  Só para o laboratório. Ativa o WinRM em HTTP (porta 5985). A autenticação NTLM cifra
  as mensagens, mas em ambientes reais usa-se HTTPS. Corre-o no DC01 e no WS01 (depois
  de juntar ao domínio) e testa a partir do Mac com: ansible windows -m ansible.windows.win_ping

.EXAMPLE
  .\06-preparar-ansible.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

Enable-PSRemoting -Force -SkipNetworkProfileCheck
Set-Service WinRM -StartupType Automatic

Get-Service WinRM | Format-Table Name, Status, StartType -AutoSize
winrm enumerate winrm/config/listener
