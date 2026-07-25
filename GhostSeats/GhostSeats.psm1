#Requires -Version 5.1
Set-StrictMode -Version Latest

$script:GhostSeatsRoot = $PSScriptRoot
$script:GhostSeatsConfig = $null

$private = Get-ChildItem -Path (Join-Path $PSScriptRoot 'Private') -Filter '*.ps1' -ErrorAction SilentlyContinue
foreach ($file in $private) {
    . $file.FullName
}

$public = Get-ChildItem -Path (Join-Path $PSScriptRoot 'Public') -Filter '*.ps1' -ErrorAction SilentlyContinue
foreach ($file in $public) {
    . $file.FullName
}

Export-ModuleMember -Function @(
    'Connect-GhostSeats'
    'Disconnect-GhostSeats'
    'Get-GhostSeat'
    'Get-GhostSeatSummary'
    'Export-GhostSeatReport'
    'New-GhostSeatApprovalList'
    'Invoke-GhostSeatReclaim'
    'Invoke-GhostSeatAutomation'
    'Get-GhostSeatSkuCatalog'
    'Get-GhostSeatConfig'
    'Set-GhostSeatConfig'
    'Start-GhostSeatDemo'
    'Show-GhostSeatBanner'
) -Alias @('ggs', 'egsr', 'igs')
