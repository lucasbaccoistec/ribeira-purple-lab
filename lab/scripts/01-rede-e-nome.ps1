#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Muda o nome do computador e fixa o endereço de rede (o mesmo que as opções 2 e 8 do SConfig).

.DESCRIPTION
  Corre-o na consola da máquina, não por ligação remota: mudar o endereço corta a ligação.
  No fim reinicia a máquina com Restart-Computer.

.EXAMPLE
  .\01-rede-e-nome.ps1 -Name DC01 -IPAddress 192.168.64.10 -Gateway 192.168.64.1
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Name,
    [Parameter(Mandatory)][string]$IPAddress,
    [Parameter(Mandatory)][string]$Gateway,
    [ValidateRange(8, 30)][int]$PrefixLength = 24,
    [string]$DnsServer
)

$ErrorActionPreference = 'Stop'
if (-not $DnsServer) { $DnsServer = $Gateway }

$adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1
if (-not $adapter) { throw 'Não encontrei nenhum adaptador de rede ligado.' }
Write-Host "Adaptador: $($adapter.Name)"

# Tira o endereço automático (DHCP) e fixa o novo.
Set-NetIPInterface -InterfaceIndex $adapter.ifIndex -Dhcp Disabled
Get-NetRoute -InterfaceIndex $adapter.ifIndex -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue |
    Remove-NetRoute -Confirm:$false
Get-NetIPAddress -InterfaceIndex $adapter.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Remove-NetIPAddress -Confirm:$false
New-NetIPAddress -InterfaceIndex $adapter.ifIndex -IPAddress $IPAddress `
    -PrefixLength $PrefixLength -DefaultGateway $Gateway | Out-Null
Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses $DnsServer

if ($env:COMPUTERNAME -ne $Name) {
    Rename-Computer -NewName $Name -Force
    Write-Host "Nome mudado para $Name."
}

Write-Host 'Feito. Reinicia a máquina com: Restart-Computer'
