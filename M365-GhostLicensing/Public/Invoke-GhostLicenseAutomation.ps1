function Invoke-GhostLicenseAutomation {
    <#
    .SYNOPSIS
        End-to-end automation: scan → report → approval list → optional reclaim.
    .DESCRIPTION
        Designed for Azure Automation / Task Scheduler / GitHub Actions:

        1. Connect (demo or Graph)
        2. Discover ghost licenses
        3. Export HTML/CSV/JSON reports
        4. Write an approval CSV
        5. Optionally reclaim rows already Approved=true (disabled accounts can be pre-approved)

        Reclaim remains opt-in and defaults to -WhatIf safety unless -ExecuteReclaim is specified.
    .PARAMETER OutputPath
        Folder for reports and approval artifacts.
    .PARAMETER AutoApproveDisabled
        Pre-mark DisabledAccount rows as Approved=true in the approval list.
    .PARAMETER ExecuteReclaim
        Actually process Approved=true rows (still Graph-gated; demo simulates).
    .PARAMETER OpenReport
        Open the HTML report when finished.
    .EXAMPLE
        Invoke-GhostLicenseAutomation -OutputPath ./out -OpenReport
    .EXAMPLE
        Invoke-GhostLicenseAutomation -OutputPath ./out -AutoApproveDisabled -ExecuteReclaim -WhatIf
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$OutputPath,

        [ValidateRange(1, 3650)]
        [int]$InactiveDays,

        [switch]$AutoApproveDisabled,

        [switch]$ExecuteReclaim,

        [switch]$OpenReport,

        [ValidateSet('Html', 'Csv', 'Json')]
        [string[]]$Format = @('Html', 'Csv', 'Json')
    )

    $config = Get-GhostLicensingConfigStore
    if (-not $config.Connected) {
        Write-Host 'No session detected — starting Contoso DEMO connection.' -ForegroundColor Yellow
        Connect-GhostLicensing -Demo | Out-Null
    }

    if (-not $OutputPath) {
        $OutputPath = Join-Path $config.DefaultReportPath ("Automation-{0:yyyyMMdd-HHmmss}" -f [datetime]::UtcNow)
    }
    if (-not (Test-Path -LiteralPath $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    }

    Show-GhostLicensingBanner

    $getParams = @{}
    if ($PSBoundParameters.ContainsKey('InactiveDays')) { $getParams.InactiveDays = $InactiveDays }

    Write-Host "`n[1/4] Scanning for ghost licenses..." -ForegroundColor Cyan
    $seats = @(Get-GhostLicense @getParams)
    $summary = $seats | Get-GhostLicenseSummary

    Write-Host ("      Found {0} ghost licenses · ~`${1}/mo · ~`${2}/yr" -f `
        $summary.GhostLicenseCount, $summary.EstimatedMonthlyWasteUSD, $summary.EstimatedAnnualWasteUSD) -ForegroundColor Green

    Write-Host "[2/4] Exporting reports..." -ForegroundColor Cyan
    $export = $seats | Export-GhostLicenseReport -Path (Join-Path $OutputPath 'GhostLicense-Report') -Format $Format -Open:$OpenReport

    Write-Host "[3/4] Building approval list..." -ForegroundColor Cyan
    $approvalPath = Join-Path $OutputPath 'GhostLicense-Approval.csv'
    $approvalParams = @{
        Path = $approvalPath
    }
    if ($AutoApproveDisabled) { $approvalParams.PreApproveDisabledAccounts = $true }
    $null = $seats | New-GhostLicenseApprovalList @approvalParams

    $reclaimResults = @()
    Write-Host "[4/4] Reclaim stage..." -ForegroundColor Cyan
    if ($ExecuteReclaim) {
        if ($PSCmdlet.ShouldProcess($approvalPath, 'Process approved reclaim rows')) {
            $reclaimResults = @(Invoke-GhostLicenseReclaim -ApprovalListPath $approvalPath)
        }
    }
    else {
        Write-Host '      Skipped reclaim (pass -ExecuteReclaim to process Approved=true rows).' -ForegroundColor DarkYellow
        Write-Host '      Tip: review the approval CSV, set Approved=true, then re-run with -ExecuteReclaim -WhatIf' -ForegroundColor DarkYellow
    }

    $result = [pscustomobject]@{
        PSTypeName      = 'M365.GhostLicensing.AutomationResult'
        Summary         = $summary
        ReportPaths     = $export.Paths
        ApprovalList    = $approvalPath
        ReclaimResults  = $reclaimResults
        OutputPath      = $OutputPath
        CompletedAtUtc  = [datetime]::UtcNow
    }

    Write-GhostLicensingAudit -Action 'Invoke-GhostLicenseAutomation' -Data @{
        outputPath = $OutputPath
        seats      = $summary.GhostLicenseCount
        reclaim    = [bool]$ExecuteReclaim
    }

    Write-Host "`nAutomation complete → $OutputPath" -ForegroundColor Green
    return $result
}
