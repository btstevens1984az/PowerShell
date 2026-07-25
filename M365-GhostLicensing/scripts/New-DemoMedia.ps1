#Requires -Version 7.0
<#
.SYNOPSIS
    Generates ~5 second M365-GhostLicensing demo videos/GIFs for the GitHub README.
#>
[CmdletBinding()]
param(
    [string]$OutputDir = (Join-Path $PSScriptRoot '..' 'demos' 'media'),
    [string]$ModulePath = (Join-Path $PSScriptRoot '..' 'M365-GhostLicensing.psd1')
)

$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

Import-Module $ModulePath -Force

$artifactRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("M365-GhostLicensing-DemoMedia-{0:yyyyMMddHHmmss}" -f [datetime]::UtcNow)
New-Item -ItemType Directory -Path $artifactRoot -Force | Out-Null

Write-Host "Running Contoso demo into $artifactRoot" -ForegroundColor Cyan
$demo = Start-GhostLicensingDemo -OutputPath $artifactRoot -OpenReport:$false -SkipReclaimSimulation:$false

$htmlReport = $demo.ReportPaths.Html
$moduleRoot = Split-Path $PSScriptRoot -Parent
$demoBoard = Join-Path $moduleRoot 'demos/html/ghostlicensing-demo.html'
$authBoard = Join-Path $moduleRoot 'demos/html/ghostlicensing-auth.html'

function Invoke-ChromeRecord {
    param(
        [string]$Url,
        [string]$OutMp4,
        [int]$Seconds = 5,
        [string]$WindowName
    )

    $chrome = (Get-Command google-chrome -ErrorAction SilentlyContinue).Source
    if (-not $chrome) { throw 'google-chrome not found' }

    $chromeProfile = Join-Path $artifactRoot "chrome-$WindowName"
    New-Item -ItemType Directory -Path $chromeProfile -Force | Out-Null

    $chromeArgs = @(
        "--user-data-dir=$chromeProfile"
        '--no-first-run'
        '--no-default-browser-check'
        '--disable-features=TranslateUI,ChromeWhatsNewUI'
        '--disable-infobars'
        '--disable-notifications'
        '--disable-component-update'
        '--disable-background-networking'
        '--window-size=1280,800'
        '--window-position=40,40'
        "--app=$Url"
    )

    $proc = Start-Process -FilePath $chrome -ArgumentList $chromeArgs -PassThru
    Start-Sleep -Seconds 2.5

    $ffmpegArgs = @(
        '-y'
        '-video_size', '1280x720'
        '-framerate', '30'
        '-f', 'x11grab'
        '-i', ':1+40,40'
        '-t', "$Seconds"
        '-an'
        '-c:v', 'libx264'
        '-pix_fmt', 'yuv420p'
        '-movflags', '+faststart'
        $OutMp4
    )
    & ffmpeg @ffmpegArgs 2>$null
    if ($proc -and -not $proc.HasExited) {
        Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
    }
}

function ConvertTo-Gif {
    param([string]$Mp4, [string]$Gif)
    $palette = [System.IO.Path]::ChangeExtension($Gif, 'png')
    & ffmpeg -y -i $Mp4 -vf 'fps=15,scale=960:-1:flags=lanczos,palettegen' $palette 2>$null
    & ffmpeg -y -i $Mp4 -i $palette -lavfi 'fps=15,scale=960:-1:flags=lanczos[x];[x][1:v]paletteuse' $Gif 2>$null
    Remove-Item -LiteralPath $palette -ErrorAction SilentlyContinue
}

$autoHtml = Join-Path $artifactRoot 'automation-board.html'
@"
<!DOCTYPE html>
<html><head><meta charset='utf-8'><title>M365-GhostLicensing Automation</title>
<style>
body{margin:0;background:#0b1118;color:#eaf2ff;font-family:Segoe UI,sans-serif}
.wrap{width:1280px;height:720px;padding:48px;background:radial-gradient(900px 500px at 10% -10%,rgba(61,214,198,.2),transparent 55%),#0b1118}
h1{font-size:40px;margin:0 0 8px} h1 span{color:#3dd6c6}
.sub{color:#8ea0b5;font-size:20px;margin-bottom:28px}
.step{opacity:0;transform:translateY(10px);animation:up .45s ease forwards;background:#121a24;border:1px solid #243142;border-radius:14px;padding:18px 20px;margin:12px 0;font-size:22px}
.step:nth-child(1){animation-delay:.2s}.step:nth-child(2){animation-delay:.7s}.step:nth-child(3){animation-delay:1.2s}.step:nth-child(4){animation-delay:1.7s}
@keyframes up{to{opacity:1;transform:none}}
.ok{color:#3dd6c6;font-weight:700}
</style></head>
<body><div class='wrap'>
<h1>M365-<span>GhostLicensing</span></h1>
<div class='sub'>scan → report → approval → simulated reclaim</div>
<div class='step'>[1/4] Found <span class='ok'>$($demo.Summary.GhostLicenseCount)</span> ghost licenses</div>
<div class='step'>[2/4] Exported HTML / CSV / JSON</div>
<div class='step'>[3/4] Approval list ready · disabled accounts pre-approved</div>
<div class='step'>[4/4] Demo reclaim simulated · <span class='ok'>`$0 tenant risk</span></div>
</div></body></html>
"@ | Set-Content -LiteralPath $autoHtml -Encoding UTF8

$clips = @(
    @{ Name = 'ghostlicensing-auth'; Url = "file://$authBoard"; Seconds = 5 }
    @{ Name = 'ghostlicensing-scan'; Url = "file://$demoBoard"; Seconds = 5 }
    @{ Name = 'ghostlicensing-report'; Url = "file://$htmlReport"; Seconds = 5 }
    @{ Name = 'ghostlicensing-automation'; Url = "file://$autoHtml"; Seconds = 5 }
)

foreach ($clip in $clips) {
    $mp4 = Join-Path $OutputDir "$($clip.Name).mp4"
    $gif = Join-Path $OutputDir "$($clip.Name).gif"
    Write-Host "Recording $($clip.Name) ($($clip.Seconds)s)..." -ForegroundColor Cyan
    Invoke-ChromeRecord -Url $clip.Url -OutMp4 $mp4 -Seconds $clip.Seconds -WindowName $clip.Name
    ConvertTo-Gif -Mp4 $mp4 -Gif $gif
    Write-Host "  → $mp4" -ForegroundColor Green
    Write-Host "  → $gif" -ForegroundColor Green
}

Write-Host "`nDemo media written to $OutputDir" -ForegroundColor Green
Get-ChildItem $OutputDir | Select-Object Name, Length, LastWriteTime
