function New-GhostSeatApprovalList {
    <#
    .SYNOPSIS
        Creates an approval CSV that managers/IT can review before reclaim automation runs.
    .DESCRIPTION
        Rows default to Approved=false. Set Approved=true for seats you want
        Invoke-GhostSeatReclaim / Invoke-GhostSeatAutomation to process.
    .EXAMPLE
        New-GhostSeatApprovalList -Path ./approvals/week12.csv
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(ValueFromPipeline)]
        [psobject]$InputObject,

        [Parameter(Mandatory)]
        [string]$Path,

        [ValidateSet('DisabledAccount', 'NeverSignedIn', 'Inactive', 'GuestWithLicense')]
        [string[]]$Category,

        [switch]$PreApproveDisabledAccounts
    )

    begin {
        $seats = New-Object System.Collections.Generic.List[object]
    }
    process {
        if ($PSBoundParameters.ContainsKey('InputObject') -and $null -ne $InputObject) {
            $seats.Add($InputObject)
        }
    }
    end {
        if ($seats.Count -eq 0) {
            $params = @{}
            if ($Category) { $params.Category = $Category }
            foreach ($item in @(Get-GhostSeat @params)) {
                $seats.Add($item)
            }
        }

        $rows = foreach ($s in $seats) {
            $approved = $false
            if ($PreApproveDisabledAccounts -and $s.Category -eq 'DisabledAccount') {
                $approved = $true
            }

            [pscustomobject]@{
                Approved              = $approved
                UserPrincipalName     = $s.UserPrincipalName
                DisplayName           = $s.DisplayName
                Category              = $s.Category
                LicenseSummary        = $s.LicenseSummary
                SkuPartNumbers        = ($s.Licenses.SkuPartNumber -join ';')
                EstimatedMonthlyWasteUSD = $s.EstimatedMonthlyWasteUSD
                ReviewerNotes         = ''
                Id                    = $s.Id
            }
        }

        $dir = Split-Path -Parent $Path
        if ($dir -and -not (Test-Path -LiteralPath $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }

        if ($PSCmdlet.ShouldProcess($Path, 'Write approval CSV')) {
            $rows | Export-Csv -LiteralPath $Path -NoTypeInformation -Encoding UTF8
            Write-GhostSeatAudit -Action 'New-GhostSeatApprovalList' -Data @{ path = $Path; count = @($rows).Count }
        }

        Get-Item -LiteralPath $Path
    }
}
