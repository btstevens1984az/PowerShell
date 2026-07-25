#Requires -Version 5.1
Set-StrictMode -Version Latest

$script:GhostLicensingRoot = $PSScriptRoot
$script:GhostLicensingConfig = $null

$private = Get-ChildItem -Path (Join-Path $PSScriptRoot 'Private') -Filter '*.ps1' -ErrorAction SilentlyContinue
foreach ($file in $private) {
    . $file.FullName
}

$public = Get-ChildItem -Path (Join-Path $PSScriptRoot 'Public') -Filter '*.ps1' -ErrorAction SilentlyContinue
foreach ($file in $public) {
    . $file.FullName
}

Export-ModuleMember -Function @(
    'Connect-GhostLicensing'
    'Disconnect-GhostLicensing'
    'Get-GhostLicense'
    'Get-GhostLicenseSummary'
    'Export-GhostLicenseReport'
    'New-GhostLicenseApprovalList'
    'Invoke-GhostLicenseReclaim'
    'Invoke-GhostLicenseAutomation'
    'Get-GhostLicenseSkuCatalog'
    'Get-GhostLicensingConfig'
    'Set-GhostLicensingConfig'
    'Start-GhostLicensingDemo'
    'Show-GhostLicensingBanner'
) -Alias @('ggl', 'eglr', 'iglr')
