#Requires -Version 7.0
<#
.SYNOPSIS
    Publishes M365-GhostLicensing to the PowerShell Gallery.

.DESCRIPTION
    Requires a NuGet API key from https://www.powershellgallery.com/account/apikeys
    Pass -NuGetApiKey or set environment variable PSGALLERY_API_KEY.

.EXAMPLE
    $env:PSGALLERY_API_KEY = '<your-key>'
    pwsh -File ./scripts/Publish-ToPSGallery.ps1

.EXAMPLE
    pwsh -File ./scripts/Publish-ToPSGallery.ps1 -NuGetApiKey '<your-key>' -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$NuGetApiKey = $env:PSGALLERY_API_KEY,

    [string]$ModuleRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($NuGetApiKey)) {
    throw @"
No PowerShell Gallery API key provided.

1. Sign in at https://www.powershellgallery.com
2. Account → API Keys → Create
3. Run:

   `$env:PSGALLERY_API_KEY = '<key>'
   pwsh -File ./scripts/Publish-ToPSGallery.ps1
"@
}

$manifest = Join-Path $ModuleRoot 'M365-GhostLicensing.psd1'
if (-not (Test-Path -LiteralPath $manifest)) {
    throw "Manifest not found: $manifest"
}

Test-ModuleManifest -Path $manifest | Out-Null
Write-Host "Publishing $manifest to PSGallery..." -ForegroundColor Cyan

if ($PSCmdlet.ShouldProcess($manifest, 'Publish-Module to PSGallery')) {
    Publish-Module -Path $ModuleRoot -NuGetApiKey $NuGetApiKey -Repository PSGallery -Verbose
    Write-Host "Published. Package URL:" -ForegroundColor Green
    Write-Host "https://www.powershellgallery.com/packages/M365-GhostLicensing"
}
