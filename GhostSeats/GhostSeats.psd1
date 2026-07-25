@{
    RootModule             = 'GhostSeats.psm1'
    ModuleVersion          = '0.1.0'
    GUID                   = 'b7e3c9a1-4f2d-4a8e-9c31-6d0f8e2a5b17'
    Author                 = 'Brad Hurt / btstevens1984az'
    CompanyName            = 'btstevens1984az'
    Copyright              = '(c) 2026 btstevens1984az. MIT License.'
    Description            = @'
GhostSeats finds unused Microsoft 365 licenses ("ghost seats") and helps IT reclaim them safely.

Detect inactive, never-signed-in, and disabled-but-licensed accounts. Estimate monthly waste,
export HTML/CSV/JSON reports, generate approval lists, and automate reclaim with WhatIf,
exclusions, and audit logging. Includes a full Contoso demo tenant — no Graph connection required.
'@
    PowerShellVersion      = '5.1'
    CompatiblePSEditions   = @('Desktop', 'Core')
    FunctionsToExport      = @(
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
    )
    CmdletsToExport        = @()
    VariablesToExport      = @()
    AliasesToExport        = @(
        'ggs'
        'egsr'
        'igs'
    )
    FormatsToProcess       = @('GhostSeats.Format.ps1xml')
    PrivateData            = @{
        PSData = @{
            Tags         = @(
                'Microsoft365', 'Office365', 'EntraID', 'AzureAD', 'Licensing',
                'CostOptimization', 'ITAdmin', 'Graph', 'GhostSeats', 'Reporting',
                'Automation', 'FinOps'
            )
            LicenseUri   = 'https://opensource.org/licenses/MIT'
            ProjectUri   = 'https://github.com/btstevens1984az/PowerShell'
            ReleaseNotes = @'
## 0.1.0
- Initial release candidate (not published to PowerShell Gallery until approved)
- Demo mode with Contoso synthetic tenant
- Waste detection: NeverSignedIn, Inactive, DisabledAccount, GuestWithLicense
- HTML / CSV / JSON reporting with cost estimates
- Approval-list reclaim automation with -WhatIf and audit log
- Configurable inactivity threshold, SKU prices, and exclusion patterns
'@
        }
    }
}
