#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Instala a autoridade de certificação da empresa (passo 4 do guia, é um bónus).

.DESCRIPTION
  Corre-o no DC01 com o domínio já a funcionar. Limite: se passar de 45 minutos, pára
  e volta à cópia DC01-limpo; o projeto continua sem esta parte.

.EXAMPLE
  .\04-instalar-adcs.ps1
#>
[CmdletBinding()]
param(
    [string]$CaName = 'Ribeira-CA'
)

$ErrorActionPreference = 'Stop'

Install-WindowsFeature ADCS-Cert-Authority -IncludeManagementTools

$elapsed = Measure-Command {
    $result = Install-AdcsCertificationAuthority -CAType EnterpriseRootCa -CACommonName $CaName `
        -CryptoProviderName 'RSA#Microsoft Software Key Storage Provider' `
        -KeyLength 2048 -HashAlgorithmName SHA256 `
        -ValidityPeriod Years -ValidityPeriodUnits 5 -Force
}
if ($result -and $result.ErrorId) {
    throw "A configuração da autoridade de certificação falhou: $($result.ErrorString)"
}
Write-Host ('Instalação da autoridade de certificação: {0:N1} minutos' -f $elapsed.TotalMinutes)

# Auditoria da própria autoridade de certificação: sem isto não há eventos de pedidos
# e emissões de certificados (4886, 4887), mesmo com a auditoria do Windows ligada.
certutil -setreg CA\AuditFilter 127
if ($LASTEXITCODE -ne 0) { throw 'O certutil não conseguiu ligar a auditoria da autoridade de certificação.' }
Restart-Service CertSvc

Get-Service CertSvc | Format-Table Name, Status -AutoSize
certutil -ping
