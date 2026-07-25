#Requires -Version 7.0
<#
.SYNOPSIS
    Records 5–10 second LIVE terminal demos of M365-GhostLicensing (Contoso demo mode).
#>
[CmdletBinding()]
param(
    [string]$OutputDir = (Join-Path $PSScriptRoot '..' 'demos' 'media'),
    [string]$ModulePath = (Join-Path $PSScriptRoot '..' 'M365-GhostLicensing.psd1')
)

$ErrorActionPreference = 'Stop'
if (-not (Get-Command xterm -ErrorAction SilentlyContinue)) {
    throw 'xterm is required for live terminal capture.'
}
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    throw 'ffmpeg is required for live terminal capture.'
}

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
$work = Join-Path ([IO.Path]::GetTempPath()) ("live-demo-{0:yyyyMMddHHmmss}" -f [datetime]::UtcNow)
New-Item -ItemType Directory -Path $work -Force | Out-Null

function ConvertTo-Gif {
    param([string]$Mp4, [string]$Gif)
    $palette = Join-Path $work ([IO.Path]::GetFileNameWithoutExtension($Gif) + '-palette.png')
    & ffmpeg -y -i $Mp4 -vf 'fps=12,scale=1100:-1:flags=lanczos,palettegen' $palette 2>$null
    & ffmpeg -y -i $Mp4 -i $palette -lavfi 'fps=12,scale=1100:-1:flags=lanczos[x];[x][1:v]paletteuse' $Gif 2>$null
}

function Start-LiveClip {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$ScriptBody,
        [int]$Seconds = 8
    )

    $runner = Join-Path $work "$Name.sh"
    $ps1 = Join-Path $work "$Name.ps1"
    Set-Content -LiteralPath $ps1 -Value $ScriptBody -Encoding UTF8

    @"
#!/bin/bash
export TERM=xterm-256color
clear
pwsh -NoProfile -File '$ps1'
sleep 12
"@ | Set-Content -LiteralPath $runner -Encoding UTF8
    chmod +x $runner

    $mp4 = Join-Path $OutputDir "$Name.mp4"
    $gif = Join-Path $OutputDir "$Name.gif"

    Write-Host "Recording $Name ($Seconds s)..." -ForegroundColor Cyan
    # Use a single-token face name so xterm does not mis-parse spaced font args as -e.
    $xterm = Start-Process -FilePath xterm -ArgumentList @(
        '-geometry', '150x36+40+40',
        '-fa', 'DejaVuSansMono',
        '-fs', '12',
        '-bg', '#0b1118',
        '-fg', '#eaf2ff',
        '-title', 'M365-GhostLicensing',
        '-e', '/bin/bash', $runner
    ) -PassThru

    Start-Sleep -Seconds 1.5
    & ffmpeg -y -video_size 1280x720 -framerate 30 -f x11grab -i ':1+40,40' -t $Seconds -an `
        -c:v libx264 -pix_fmt yuv420p -movflags '+faststart' $mp4 2>$null

    if ($xterm -and -not $xterm.HasExited) {
        Stop-Process -Id $xterm.Id -Force -ErrorAction SilentlyContinue
    }
    Get-Process xterm -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

    ConvertTo-Gif -Mp4 $mp4 -Gif $gif
    Write-Host "  → $mp4" -ForegroundColor Green
    Write-Host "  → $gif" -ForegroundColor Green
}

$auth = @"
`$ErrorActionPreference = 'Continue'
Import-Module '$ModulePath' -Force
Clear-Host
Show-GhostLicensingBanner
Start-Sleep -Milliseconds 600
Write-Host ''
Write-Host '  Connecting to Azure Entra / Demo tenant...' -ForegroundColor Yellow
Start-Sleep -Milliseconds 500
Connect-GhostLicensing -Demo | Format-List Mode, AuthMethod, TenantId, TenantName, Connected
Start-Sleep -Seconds 6
"@

$scan = @"
`$ErrorActionPreference = 'Continue'
Import-Module '$ModulePath' -Force
Connect-GhostLicensing -Demo | Out-Null
Clear-Host
Write-Host 'PS> Get-GhostLicense | Format-Table -AutoSize' -ForegroundColor Cyan
Get-GhostLicense | Select-Object -First 8 DisplayName, Category, LicenseSummary, EstimatedMonthlyWasteUSD | Format-Table -AutoSize
Write-Host ''
Write-Host 'PS> Get-GhostLicenseSummary' -ForegroundColor Cyan
Get-GhostLicenseSummary | Format-List GhostLicenseCount, EstimatedMonthlyWasteUSD, EstimatedAnnualWasteUSD, DisabledAccountCount, NeverSignedInCount, InactiveCount
Start-Sleep -Seconds 6
"@

$auto = @"
`$ErrorActionPreference = 'Continue'
Import-Module '$ModulePath' -Force
Connect-GhostLicensing -Demo | Out-Null
Clear-Host
`$out = Join-Path ([IO.Path]::GetTempPath()) 'M365-GhostLicensing-LiveDemo'
Write-Host 'PS> Invoke-GhostLicenseAutomation -OutputPath `$out -AutoApproveDisabled' -ForegroundColor Cyan
Write-Host ''
Invoke-GhostLicenseAutomation -OutputPath `$out -AutoApproveDisabled | Out-Null
Write-Host ''
Write-Host 'PS> Get-ChildItem `$out -Recurse | Select Name, Length' -ForegroundColor Cyan
Get-ChildItem `$out -Recurse -File | Select-Object Name, Length | Format-Table -AutoSize
Start-Sleep -Seconds 6
"@

Start-LiveClip -Name 'live-auth' -ScriptBody $auth -Seconds 8
Start-LiveClip -Name 'live-scan' -ScriptBody $scan -Seconds 9
Start-LiveClip -Name 'live-automation' -ScriptBody $auto -Seconds 10

Write-Host "`nLive demo media written to $OutputDir" -ForegroundColor Green
Get-ChildItem $OutputDir -Filter 'live-*' | Select-Object Name, Length, LastWriteTime
