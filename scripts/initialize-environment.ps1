#Requires -Version 4

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

# see http://get-carbon.org/help/ for Carbon documentation
& (Join-Path $PSSCriptRoot Carbon\Import-Carbon.ps1 -Resolve)

if (!(Test-AdminPrivilege))
{
    throw "This script must be run as an administrator"
}

if (!(Test-Service -Name "W3SVC"))
{
    throw "The W3SVC service does not exist, is IIS installed?"
}

# //////////////////////////////////////////////////////////////////////
# // GLOBAL VARIABLES
# //////////////////////////////////////////////////////////////////////

$siteName = "ContosoUniversity"
$domain = "contosouniversity.localtest.me"
$sslCertificateName = "contosouniversity.localtest.me.pfx"
$appPoolName = "ContosoUniversityAppPool"

$sslCertificatePath = [IO.Path]::Combine($PSSCriptRoot, "..\certificates\", $sslCertificateName)
$websitePath = [IO.Path]::Combine($PSSCriptRoot, "..\src\ContosoUniversity.Web")

$httpPort  = 50930
$httpsPort = 50931

# //////////////////////////////////////////////////////////////////////
# // IMPORT CERTIFICATES
# //////////////////////////////////////////////////////////////////////

Write-Host "Importing $sslCertificateName into Local Computer\Personal store" -foregroundcolor yellow

$sslCertificate = Install-Certificate `
                        -Path $sslCertificatePath `
                        -StoreLocation LocalMachine `
                        -StoreName My `
                        -Exportable `
                        -Password password

Write-Host ">>> done" -foregroundcolor green
Write-Host

Write-Host "Importing $sslCertificateName into Local Computer\Trusted Root store" -foregroundcolor yellow

$sslCertificate = Install-Certificate `
                        -Path $sslCertificatePath `
                        -StoreLocation LocalMachine `
                        -StoreName Root `
                        -Exportable `
                        -Password password

Write-Host ">>> done" -foregroundcolor green
Write-Host

# //////////////////////////////////////////////////////////////////////
# // INITIALIZE APPPOOL
# //////////////////////////////////////////////////////////////////////

if (Test-IisAppPool -Name $appPoolName) {
    Write-Host "Application pool '$appPoolName' already exists .. deleting" -foregroundcolor magenta
    Uninstall-IisAppPool -Name $appPoolName
}

Write-Host "Creating application pool '$appPoolName'" -foregroundcolor yellow

Install-IisAppPool -Name $appPoolName `
                   -ServiceAccount NetworkService `
                   -ManagedRuntimeVersion "v4.0"

If (!(Test-IisAppPool -Name $appPoolName)) {
  throw "Creating application pool failed !! "
}

Write-Host ">>> done" -foregroundcolor green
Write-Host

# //////////////////////////////////////////////////////////////////////
# // INITIALIZE WEBSITE
# //////////////////////////////////////////////////////////////////////

if (Test-IisWebsite -Name $siteName) {
    Write-Host "Website '$siteName' already exists .. deleting" -foregroundcolor magenta
    Uninstall-IisWebsite -Name $siteName
}

Write-Host "Creating website '$siteName'" -foregroundcolor yellow

$httpBinding = "http/*:$($httpPort):"
$httpsBinding = "https/*:$($httpsPort):"

Write-Host " - $httpBinding" -foregroundcolor yellow
Write-Host " - $httpsBinding" -foregroundcolor yellow

Install-IisWebsite -Path $websitePath `
                   -Name $siteName `
                   -Bindings ($httpBinding, $httpsBinding) `
                   -AppPoolName $appPoolName

If (!(Test-IisWebsite -Name $siteName)) {
  throw "Creating website failed !! "
}

Write-Host ">>> done" -foregroundcolor green
Write-Host

# //////////////////////////////////////////////////////////////////////
# // SET SSL BINDINGS
# //////////////////////////////////////////////////////////////////////

Write-Host "Setting SSL binding for thumbprint $($sslCertificate.Thumbprint) for port $httpsPort" -foregroundcolor yellow

Set-SslCertificateBinding -ApplicationID ([Guid]::NewGuid()) `
                          -Thumbprint $sslCertificate.Thumbprint `
                          -Port $httpsPort

If (!(Test-SslCertificateBinding -Port $httpsPort)) {
  throw "Setting SSL binding failed !! "
}

Write-Host ">>> done" -foregroundcolor green
Write-Host

Write-Host "========================================================================" -foregroundcolor yellow
Write-Host ""
Write-Host " Setup complete, you can now access the site at:"
Write-Host ""
Write-Host " https://$($domain):$($httpsPort)" -foregroundcolor green
Write-Host ""
Write-Host "========================================================================" -foregroundcolor yellow
