#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Instala o Active Directory e cria o domínio ribeira.test (passo 3 do guia da semana 0).

.DESCRIPTION
  Pede a palavra-passe do modo de restauro do diretório (DSRM). No fim o servidor
  reinicia sozinho. Anota o tempo desde que carregas Enter até aparecer o ecrã de
  início de sessão (o critério é 90 minutos ou menos).

.EXAMPLE
  .\02-instalar-ad.ps1
#>
[CmdletBinding()]
param(
    [string]$DomainName = 'ribeira.test',
    [string]$NetbiosName = 'RIBEIRA'
)

$ErrorActionPreference = 'Stop'

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

$dsrm = Read-Host -AsSecureString 'Palavra-passe DSRM (modo de restauro do diretório)'
Install-ADDSForest -DomainName $DomainName -DomainNetbiosName $NetbiosName -InstallDns `
    -SafeModeAdministratorPassword $dsrm -Force
