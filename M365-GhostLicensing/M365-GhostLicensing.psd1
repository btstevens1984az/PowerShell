@{
    RootModule             = 'M365-GhostLicensing.psm1'
    ModuleVersion          = '0.1.0'
    GUID                   = 'b7e3c9a1-4f2d-4a8e-9c31-6d0f8e2a5b17'
    Author                 = 'btstevens1984az'
    CompanyName            = 'btstevens1984az'
    Copyright              = '(c) 2026 btstevens1984az. MIT License.'
    Description            = @'
M365-GhostLicensing finds unused Microsoft 365 licenses ("ghost licenses") and helps IT reclaim them safely.

Detect inactive, never-signed-in, and disabled-but-licensed accounts. Estimate monthly waste,
export HTML/CSV/JSON reports, generate approval lists, and automate reclaim with WhatIf,
exclusions, and audit logging. Includes a full Contoso demo tenant — no Graph connection required.
'@
    PowerShellVersion      = '5.1'
    CompatiblePSEditions   = @('Desktop', 'Core')
    FunctionsToExport      = @(
        'Connect-GhostLicensing'
        'Disconnect-GhostLicensing'
        'Get-GhostLicense'
        'Get-GhostLicenseSummary'
        'Export-GhostLicenseReport'
        'New-GhostLicenseApprovalList'
        'Invoke-GhostLicenseReclaim'
        'Invoke-GhostLicenseAutomation'
        'Get-GhostLicenseSkuCatalog'
        'Get-GhostLicensingConfig'
        'Set-GhostLicensingConfig'
        'Start-GhostLicensingDemo'
        'Show-GhostLicensingBanner'
    )
    CmdletsToExport        = @()
    VariablesToExport      = @()
    AliasesToExport        = @(
        'ggl'
        'eglr'
        'iglr'
    )
    FormatsToProcess       = @('M365-GhostLicensing.Format.ps1xml')
    PrivateData            = @{
        PSData = @{
            Tags         = @(
                'Microsoft365', 'Office365', 'EntraID', 'AzureAD', 'Licensing',
                'CostOptimization', 'ITAdmin', 'Graph', 'M365-GhostLicensing', 'Reporting',
                'Automation', 'FinOps'
            )
            LicenseUri   = 'https://opensource.org/licenses/MIT'
            ProjectUri   = 'https://github.com/btstevens1984az/M365-GhostLicensing'
            ReleaseNotes = @'
## 0.1.0
- Initial release candidate (not published to PowerShell Gallery until approved)
- Azure Entra auth: interactive, device code, certificate, client secret, access token, demo
- Demo mode with Contoso synthetic tenant
- Waste detection: NeverSignedIn, Inactive, DisabledAccount, GuestWithLicense
- HTML / CSV / JSON reporting with cost estimates
- Approval-list reclaim automation with -WhatIf and audit log
- Configurable inactivity threshold, SKU prices, and exclusion patterns
'@
        }
    }
}
