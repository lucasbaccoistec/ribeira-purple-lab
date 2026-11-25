#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Junta este computador ao domínio ribeira.test (passo 5 do guia da semana 0).

.DESCRIPTION
  Corre-o no WS01. Primeiro aponta o DNS para o DC01 e confirma que o domínio é
  encontrado; só depois pede a palavra-passe do Administrator do domínio e junta.
  O computador reinicia no fim.

.EXAMPLE
  .\05-juntar-ao-dominio.ps1 -DcIp 192.168.64.10
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$DcIp,
    [string]$DomainName = 'ribeira.test',
    [string]$NewName = 'WS01'
)

$ErrorActionPreference = 'Stop'

Get-NetAdapter | Set-DnsClientServerAddress -ServerAddresses $DcIp

# Se isto falhar, o DNS está mal: não continues.
Resolve-DnsName $DomainName -Server $DcIp | Out-Null
Write-Host "O DNS encontra $DomainName."

$credential = Get-Credential -UserName 'RIBEIRA\Administrator' -Message 'Palavra-passe do Administrator do domínio'
Add-Computer -DomainName $DomainName -NewName $NewName -Credential $credential -Restart
