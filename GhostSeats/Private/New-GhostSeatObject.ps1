function New-GhostSeatObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [psobject]$User,

        [Parameter(Mandatory)]
        [string]$Category,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$Licenses,

        [nullable[datetime]]$LastSignIn,

        [nullable[int]]$InactiveDays,

        [string]$Reason
    )

    $licenseDetails = foreach ($lic in $Licenses) {
        $sku = if ($lic.SkuPartNumber) { $lic.SkuPartNumber } else { [string]$lic }
        $info = Resolve-SkuInfo -SkuPartNumber $sku
        [pscustomobject]@{
            SkuPartNumber = $info.SkuPartNumber
            FriendlyName  = $info.FriendlyName
            MonthlyUsd    = $info.MonthlyUsd
            SkuId         = $(if ($lic.SkuId) { $lic.SkuId } else { $null })
        }
    }

    $monthly = [decimal](($licenseDetails | Measure-Object -Property MonthlyUsd -Sum).Sum)
    $summary = ($licenseDetails | ForEach-Object { $_.FriendlyName }) -join ', '

    $obj = [pscustomobject]@{
        PSTypeName                 = 'GhostSeats.GhostSeat'
        Id                         = $User.Id
        DisplayName                = $User.DisplayName
        UserPrincipalName          = $User.UserPrincipalName
        AccountEnabled             = [bool]$User.AccountEnabled
        UserType                   = $User.UserType
        Department                 = $User.Department
        JobTitle                   = $User.JobTitle
        Category                   = $Category
        Reason                     = $Reason
        LastSignInDateTime         = $LastSignIn
        InactiveDays               = $InactiveDays
        Licenses                   = @($licenseDetails)
        LicenseSummary             = $summary
        EstimatedMonthlyWasteUSD   = [math]::Round($monthly, 2)
        EstimatedAnnualWasteUSD    = [math]::Round($monthly * 12, 2)
        RecommendedAction          = $(
            switch ($Category) {
                'DisabledAccount'   { 'Remove licenses; keep account disabled or delete per policy' }
                'NeverSignedIn'     { 'Confirm hire status; remove licenses if unused' }
                'Inactive'          { 'Notify manager; reclaim after approval window' }
                'GuestWithLicense'  { 'Remove member-SKU licenses from guest' }
                default             { 'Review and reclaim if appropriate' }
            }
        )
        Source                     = $(if ((Get-GhostSeatsConfigStore).DemoMode) { 'Demo' } else { 'Graph' })
        AnalyzedAtUtc              = [datetime]::UtcNow
    }

    return $obj
}
