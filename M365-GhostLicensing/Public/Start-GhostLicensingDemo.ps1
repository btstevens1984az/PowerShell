function Start-GhostLicensingDemo {
    <#
    .SYNOPSIS
        Runs a polished Contoso demo: scan, summarize, report, approval, simulated reclaim.
    .PARAMETER OutputPath
        Where demo artifacts are written.
    .PARAMETER OpenReport
        Open the HTML report in the default browser.
    .PARAMETER SkipReclaimSimulation
        Skip the simulated reclaim step.
    .EXAMPLE
        Start-GhostLicensingDemo -OpenReport
    #>
    [CmdletBinding()]
    param(
        [string]$OutputPath,

        [switch]$OpenReport,

        [switch]$SkipReclaimSimulation
    )

    Show-GhostLicensingBanner
    Write-Host "  DEMO ENVIRONMENT · Contoso synthetic tenant · zero risk`n" -ForegroundColor DarkCyan

    Connect-GhostLicensing -Demo | Out-Null

    if (-not $OutputPath) {
        $OutputPath = Join-Path (Get-GhostLicensingConfigStore).DefaultReportPath ("Demo-{0:yyyyMMdd-HHmmss}" -f [datetime]::UtcNow)
    }

    $automation = Invoke-GhostLicenseAutomation -OutputPath $OutputPath -AutoApproveDisabled -OpenReport:$OpenReport

    if (-not $SkipReclaimSimulation) {
        Write-Host "`nSimulating reclaim for pre-approved disabled accounts (-WhatIf)..." -ForegroundColor Cyan
        $whatIf = Invoke-GhostLicenseReclaim -ApprovalListPath $automation.ApprovalList -WhatIf
        Write-Host "WhatIf candidates: $(@($whatIf).Count)" -ForegroundColor Yellow

        Write-Host "Executing DEMO reclaim (simulated — no Graph changes)..." -ForegroundColor Cyan
        $done = Invoke-GhostLicenseReclaim -ApprovalListPath $automation.ApprovalList -Confirm:$false
        $automation | Add-Member -NotePropertyName DemoReclaimResults -NotePropertyValue $done -Force
    }

    Write-Host "`n✓ M365-GhostLicensing demo finished." -ForegroundColor Green
    Write-Host "  Reports : $($automation.OutputPath)" -ForegroundColor Gray
    if ($automation.ReportPaths.Html) {
        Write-Host "  HTML    : $($automation.ReportPaths.Html)" -ForegroundColor Gray
    }

    return $automation
}
