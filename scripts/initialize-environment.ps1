#requires -version 4.0
#requires -runasadministrator

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# see: https://technet.microsoft.com/en-us/library/ee790599.aspx
Add-PSSnapin WebAdministration -ErrorAction SilentlyContinue
Import-Module WebAdministration -ErrorAction SilentlyContinue

# //////////////////////////////////////////////////////////////////////
# // GLOBAL VARIABLES
# //////////////////////////////////////////////////////////////////////

$siteName = "ContosoUniversity"
$hostname = "contosouniversity.localtest.me"
$sslCertificateName = "contosouniversity.localtest.me.pfx"
$appPoolName = "ContosoUniversityAppPool"
$websitePath = [System.IO.Path]::GetFullPath([IO.Path]::Combine($PSSCriptRoot, "..\src\ContosoUniversity.Web"))

$sslCertificatePath = [IO.Path]::Combine($PSSCriptRoot, "..\certificates\", $sslCertificateName)
$sslCertificatePassword = ConvertTo-SecureString -String "password" -Force -AsPlainText

# //////////////////////////////////////////////////////////////////////
# // INITIALISE CERTIFICATES
# //////////////////////////////////////////////////////////////////////

Write-Host "# //////////////////////////////////////////////////////////////////////"
Write-Host "# // IMPORT CERTIFICATES"
Write-Host "# //////////////////////////////////////////////////////////////////////"
Write-Host

if (!(Test-Path -Path $sslCertificatePath))
{
    throw "The certificate could not be found at '$sslCertificatePath'"
}

$personalCertificates = @(Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Subject -eq "CN=$hostname"})
if (!($personalCertificates.length -eq 0)) {
    Write-Host "A certificate for '$hostname' already exists in LocalMachine\My .. deleting" -foregroundcolor magenta
    $personalCertificates | %{Remove-Item -path $_.PSPath -recurse -Force}
}

Write-Host "Importing $sslCertificateName into LocalMachine\My" -foregroundcolor yellow

Import-PfxCertificate -FilePath $sslCertificatePath `
                      -CertStoreLocation Cert:\LocalMachine\My `
                      -Password $sslCertificatePassword `
                      -Exportable | Out-Null

$personalCertificates = @(Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Subject -eq "CN=$hostname"})
if ($personalCertificates.length -eq 0) {
  throw "Importing $sslCertificateName failed !! "
}

Write-Host ">>> done" -foregroundcolor green
Write-Host

$rootCertificates = @(Get-ChildItem Cert:\LocalMachine\Root | Where-Object {$_.Subject -eq "CN=$hostname"})
if (!($rootCertificates.length -eq 0)) {
    Write-Host "A certificate for '$hostname' already exists in LocalMachine\Root .. deleting" -foregroundcolor magenta
    $rootCertificates | %{Remove-Item -path $_.PSPath -recurse -Force}
}

Write-Host "Importing $sslCertificateName into LocalMachine\Root" -foregroundcolor yellow

Import-PfxCertificate -FilePath $sslCertificatePath `
                      -CertStoreLocation Cert:\LocalMachine\Root `
                      -Password $sslCertificatePassword `
                      -Exportable | Out-Null

$rootCertificates = @(Get-ChildItem Cert:\LocalMachine\Root | Where-Object {$_.Subject -eq "CN=$hostname"})
if ($rootCertificates.length -eq 0) {
  throw "Importing $sslCertificateName failed !! "
}

Write-Host ">>> done" -foregroundcolor green
Write-Host

# //////////////////////////////////////////////////////////////////////
# // INITIALISE WEBSITE
# //////////////////////////////////////////////////////////////////////

if (!(Test-Path -Path $websitePath))
{
    throw "No website could be found at '$websitePath'"
}

Write-Host "//////////////////////////////////////////////////////////////////////"
Write-Host "// INITIALIZE APPPOOL"
Write-Host "//////////////////////////////////////////////////////////////////////"
Write-Host

if (Test-Path "IIS:\AppPools\$appPoolName") {
    Write-Host "Application pool '$appPoolName' already exists .. deleting" -foregroundcolor magenta
    Remove-WebAppPool -Name $appPoolName
}

Write-Host "Creating application pool '$appPoolName' [v4.0 runtime, integrated pipeline, network service]" -foregroundcolor yellow

$appPool = New-WebAppPool $appPoolName
$appPool.managedRuntimeVersion = "v4.0"
$appPool.processModel.identityType = 2 #NetworkService

$appPool | Set-Item

if (!(Test-Path "IIS:\AppPools\$appPoolName")) {
  throw "Creating application pool failed !! "
}

Write-Host ">>> done" -foregroundcolor green
Write-Host

Write-Host "//////////////////////////////////////////////////////////////////////"
Write-Host "// INITIALIZE WEBSITE"
Write-Host "//////////////////////////////////////////////////////////////////////"
Write-Host

if (Get-Website -Name $siteName) {
    Write-Host "Website '$siteName' already exists .. deleting" -foregroundcolor magenta
    Remove-Website -Name $siteName
}

Write-Host "Creating website '$siteName'" -foregroundcolor yellow

New-WebSite -Name $siteName `
            -Port 80 `
            -HostHeader $hostname `
            -PhysicalPath $websitePath `
            -ApplicationPool $appPoolName | Out-Null

if (!(Test-Path "IIS:\Sites\$siteName")) {
  throw "Creating website failed !! "
}

Write-Host ">>> done" -foregroundcolor green
Write-Host

Write-Host "//////////////////////////////////////////////////////////////////////"
Write-Host "// SET SSL BINDINGS"
Write-Host "//////////////////////////////////////////////////////////////////////"
Write-Host

if (Get-WebBinding -HostHeader $hostname -Port 443) {
    Write-Host "A bindings for '$hostname:443' already exists .. deleting" -foregroundcolor magenta
    Remove-WebBinding -HostHeader $hostname -Port 443
}

$sslCertificateThumbprint = (Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Subject -eq "CN=$hostname"}).Thumbprint

Write-Host "Setting SSL binding for thumbprint '$sslCertificateThumbprint' and site '$siteName'" -foregroundcolor yellow

New-WebBinding -Name "$siteName" `
               -Protocol "https" `
               -Port 443 `
               -HostHeader $hostname `
               -SslFlags 1 | Out-Null #Server Name Indication

# Tie together both the binding and the certificate
# see: http://blog.kloud.com.au/2013/04/18/an-overview-of-server-name-indication-sni-and-creating-an-iis-sni-web-ssl-binding-using-powershell-in-windows-server-2012/
Remove-Item -Path "IIS:\SslBindings\!443!$hostname" `
            -ErrorAction SilentlyContinue

New-Item -Path "IIS:\SslBindings\!443!$hostname" `
         -Thumbprint $sslCertificateThumbprint `
         -SSLFlags 1 | Out-Null #Server Name Indication

if (!(Get-WebBinding -HostHeader $hostname -Port 443)) {
  throw "Creating ssl binding failed !! "
}

Write-Host ">>> done" -foregroundcolor green
Write-Host