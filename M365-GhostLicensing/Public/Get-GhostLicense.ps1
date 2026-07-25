function Get-GhostLicense {
    <#
    .SYNOPSIS
        Finds Microsoft 365 ghost licenses (licensed users that look unused).
    .DESCRIPTION
        Returns GhostLicense objects for:
        - DisabledAccount: account disabled but still licensed
        - NeverSignedIn: licensed, no successful sign-in recorded
        - Inactive: no sign-in within the configured inactivity window
        - GuestWithLicense: guest users holding member SKUs

        Excludes break-glass / service / executive patterns by default.
    .PARAMETER InactiveDays
        Override session inactivity threshold (days).
    .PARAMETER Category
        Filter to one or more waste categories.
    .PARAMETER IncludeExcluded
        Include users that match exclusion patterns (for audit visibility).
    .PARAMETER MinimumMonthlyWasteUSD
        Only return seats at or above this estimated monthly waste.
    .EXAMPLE
        Connect-GhostLicensing -Demo
        Get-GhostLicense | Format-Table
    .EXAMPLE
        Get-GhostLicense -Category DisabledAccount, NeverSignedIn | Export-Csv .\ghosts.csv
    #>
    [CmdletBinding()]
    [Alias('ggl')]
    param(
        [ValidateRange(1, 3650)]
        [int]$InactiveDays,

        [ValidateSet('DisabledAccount', 'NeverSignedIn', 'Inactive', 'GuestWithLicense')]
        [string[]]$Category,

        [switch]$IncludeExcluded,

        [ValidateRange(0, 100000)]
        [decimal]$MinimumMonthlyWasteUSD,

        [switch]$IncludeGuests
    )

    $config = Get-GhostLicensingConfigStore
    if (-not $config.Connected) {
        throw "Not connected. Run Connect-GhostLicensing -Demo or Connect-GhostLicensing first."
    }

    $threshold = if ($PSBoundParameters.ContainsKey('InactiveDays')) { $InactiveDays } else { $config.InactiveDays }
    $minWaste = if ($PSBoundParameters.ContainsKey('MinimumMonthlyWasteUSD')) {
        $MinimumMonthlyWasteUSD
    }
    else {
        $config.MinimumMonthlyWasteUSD
    }
    $guests = if ($PSBoundParameters.ContainsKey('IncludeGuests')) { $IncludeGuests } else { $config.IncludeGuests }

    $cutoff = [datetime]::UtcNow.AddDays(-1 * $threshold)
    $users = @(Get-GhostLicenseUserInventory)

    $results = foreach ($user in $users) {
        if (-not $user.AssignedLicenses -or $user.AssignedLicenses.Count -eq 0) { continue }

        $isGuest = $user.UserType -eq 'Guest'
        if ($isGuest -and -not $guests -and -not ($user.AssignedLicenses.Count -gt 0)) { continue }

        $excluded = Test-GhostLicenseExcluded -User $user
        if ($excluded -and -not $IncludeExcluded) { continue }

        $last = $user.LastSignInDateTime
        $inactiveDaysValue = $null
        if ($last) {
            $inactiveDaysValue = [int][math]::Floor(([datetime]::UtcNow - [datetime]$last).TotalDays)
        }

        $cat = $null
        $reason = $null

        if (-not $user.AccountEnabled) {
            $cat = 'DisabledAccount'
            $reason = 'Account is disabled but still has assigned licenses.'
        }
        elseif ($isGuest) {
            $cat = 'GuestWithLicense'
            $reason = 'Guest account holds member product licenses.'
        }
        elseif ($null -eq $last) {
            $cat = 'NeverSignedIn'
            $reason = 'No successful sign-in activity found for a licensed account.'
        }
        elseif ([datetime]$last -lt $cutoff) {
            $cat = 'Inactive'
            $reason = "No sign-in within the last $threshold days (last: $($last.ToString('yyyy-MM-dd')))."
        }
        else {
            continue
        }

        if ($Category -and $cat -notin $Category) { continue }

        $seat = New-GhostLicenseObject -User $user -Category $cat -Licenses $user.AssignedLicenses -LastSignIn $last -InactiveDays $inactiveDaysValue -Reason $reason
        if ($excluded) {
            $seat | Add-Member -NotePropertyName IsExcluded -NotePropertyValue $true -Force
        }

        if ($seat.EstimatedMonthlyWasteUSD -lt $minWaste) { continue }
        $seat
    }

    Write-GhostLicensingAudit -Action 'Get-GhostLicense' -Data @{
        count         = @($results).Count
        inactiveDays  = $threshold
        categoryFilter = $Category
    }

    $results | Sort-Object EstimatedMonthlyWasteUSD -Descending
}
