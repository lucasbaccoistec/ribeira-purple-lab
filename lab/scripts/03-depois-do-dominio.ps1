#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Confirma que o domínio ficou bem criado, acerta o DNS e mede a velocidade (passo 3 do guia).

.DESCRIPTION
  Corre-o no DC01 depois do reinício que o script 02 provoca. O critério de velocidade
  é Get-ADUser -Filter * em 30 segundos ou menos na segunda execução.

.EXAMPLE
  .\03-depois-do-dominio.ps1
#>
[CmdletBinding()]
param(
    [string]$Forwarder = '1.1.1.1'
)

$ErrorActionPreference = 'Stop'

Get-ADDomain | Select-Object DNSRoot, NetBIOSName
Get-Service NTDS, DNS, Netlogon, Kdc | Format-Table Name, Status -AutoSize

# O servidor usa-se a si próprio como DNS e deixa o resto da internet para um DNS público.
Get-NetAdapter | Set-DnsClientServerAddress -ServerAddresses 127.0.0.1
$current = @((Get-DnsServerForwarder).IPAddress | ForEach-Object { $_.ToString() })
if ($current -notcontains $Forwarder) {
    Add-DnsServerForwarder -IPAddress $Forwarder
}

Write-Host 'A medir a velocidade (regista a segunda execução):'
1..2 | ForEach-Object {
    $elapsed = Measure-Command { Get-ADUser -Filter * | Out-Null }
    Write-Host ('  execução {0}: {1:N1} segundos' -f $_, $elapsed.TotalSeconds)
}

Write-Host 'Por fim, reinicia (Restart-Computer) e mede o tempo até poderes iniciar sessão.'
