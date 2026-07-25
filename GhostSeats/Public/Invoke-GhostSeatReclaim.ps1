function Invoke-GhostSeatReclaim {
    <#
    .SYNOPSIS
        Removes licenses from approved ghost seats (or simulates with -WhatIf).
    .DESCRIPTION
        SAFETY: Reclaim requires an approval CSV (from New-GhostSeatApprovalList) with Approved=true,
        unless -Force is used with explicit -UserPrincipalName targets (still respects -WhatIf).

        In Demo mode, no Graph changes are made — actions are simulated and audited.
    .PARAMETER ApprovalListPath
        CSV produced by New-GhostSeatApprovalList.
    .PARAMETER UserPrincipalName
        Explicit UPN targets (use with -Force for non-CSV reclaim).
    .PARAMETER Force
        Allow reclaim without an approval list when UPNs are specified.
    .EXAMPLE
        Invoke-GhostSeatReclaim -ApprovalListPath ./approvals/week12.csv -WhatIf
    .EXAMPLE
        Invoke-GhostSeatReclaim -ApprovalListPath ./approvals/week12.csv -Confirm:$false
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [Alias('igs')]
    param(
        [string]$ApprovalListPath,

        [string[]]$UserPrincipalName,

        [switch]$Force
    )

    $config = Get-GhostSeatsConfigStore
    if (-not $config.Connected) {
        throw "Not connected. Run Connect-GhostSeats first."
    }

    $targets = @()

    if ($ApprovalListPath) {
        if (-not (Test-Path -LiteralPath $ApprovalListPath)) {
            throw "Approval list not found: $ApprovalListPath"
        }
        $csv = Import-Csv -LiteralPath $ApprovalListPath
        $targets = @(
            $csv | Where-Object {
                $_.Approved -match '^(1|true|yes)$'
            }
        )
        if ($targets.Count -eq 0) {
            Write-Warning "No rows marked Approved=true in $ApprovalListPath"
            return
        }
    }
    elseif ($UserPrincipalName -and $Force) {
        $all = Get-GhostSeat -IncludeExcluded
        $targets = foreach ($upn in $UserPrincipalName) {
            $match = $all | Where-Object UserPrincipalName -eq $upn
            if (-not $match) {
                Write-Warning "No ghost seat found for $upn"
                continue
            }
            [pscustomobject]@{
                UserPrincipalName = $match.UserPrincipalName
                DisplayName       = $match.DisplayName
                Id                = $match.Id
                SkuPartNumbers    = ($match.Licenses.SkuPartNumber -join ';')
                Category          = $match.Category
            }
        }
    }
    else {
        throw "Provide -ApprovalListPath, or -UserPrincipalName with -Force. Tip: start with -WhatIf."
    }

    $results = foreach ($t in $targets) {
        $upn = $t.UserPrincipalName
        $skuParts = @()
        if ($t.SkuPartNumbers) {
            $skuParts = @($t.SkuPartNumbers -split ';' | Where-Object { $_ })
        }

        $targetLabel = "$upn [$($skuParts -join ', ')]"
        if (-not $PSCmdlet.ShouldProcess($targetLabel, 'Remove assigned licenses')) {
            [pscustomobject]@{
                UserPrincipalName = $upn
                Status            = 'Skipped'
                Mode              = $(if ($config.DemoMode) { 'Demo' } else { 'Graph' })
                RemovedSkus       = $skuParts
                Message           = 'ShouldProcess declined'
            }
            continue
        }

        if ($config.DemoMode) {
            Write-GhostSeatAudit -Action 'Invoke-GhostSeatReclaim' -Data @{
                upn     = $upn
                skus    = $skuParts
                status  = 'Simulated'
                demo    = $true
            }
            [pscustomobject]@{
                UserPrincipalName = $upn
                DisplayName       = $t.DisplayName
                Status            = 'Simulated'
                Mode              = 'Demo'
                RemovedSkus       = $skuParts
                Message           = 'Demo mode — no tenant changes were made.'
            }
            continue
        }

        try {
            $user = Get-MgUser -UserId $upn -Property Id, AssignedLicenses -ErrorAction Stop
            $skuIds = @($user.AssignedLicenses.SkuId)
            if ($skuIds.Count -eq 0) {
                [pscustomobject]@{
                    UserPrincipalName = $upn
                    Status            = 'NoLicenses'
                    Mode              = 'Graph'
                    RemovedSkus       = @()
                    Message           = 'User currently has no assigned licenses.'
                }
                continue
            }

            Set-MgUserLicense -UserId $user.Id -AddLicenses @() -RemoveLicenses $skuIds -ErrorAction Stop | Out-Null
            Write-GhostSeatAudit -Action 'Invoke-GhostSeatReclaim' -Data @{
                upn    = $upn
                skuIds = $skuIds
                status = 'Removed'
            }

            [pscustomobject]@{
                UserPrincipalName = $upn
                DisplayName       = $t.DisplayName
                Status            = 'Removed'
                Mode              = 'Graph'
                RemovedSkus       = $skuParts
                Message           = "Removed $($skuIds.Count) license SKU(s)."
            }
        }
        catch {
            Write-GhostSeatAudit -Action 'Invoke-GhostSeatReclaim' -Data @{
                upn    = $upn
                status = 'Failed'
                error  = $_.Exception.Message
            }
            [pscustomobject]@{
                UserPrincipalName = $upn
                DisplayName       = $t.DisplayName
                Status            = 'Failed'
                Mode              = 'Graph'
                RemovedSkus       = $skuParts
                Message           = $_.Exception.Message
            }
        }
    }

    $results
}
