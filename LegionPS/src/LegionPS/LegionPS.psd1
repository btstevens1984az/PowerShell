@{
    RootModule           = 'LegionPS.psm1'
    ModuleVersion        = '0.1.0'
    GUID                 = 'd5acaafc-445f-43e2-8f27-aa48b1ffa52e'
    Author               = 'LegionPS Contributors'
    CompanyName          = 'LegionPS Contributors'
    Copyright            = '(c) 2026 LegionPS Contributors. MIT License.'
    Description          = 'Secure, AI-ready PowerShell 7 module for mass parallel remote job fan-out with playbook allowlisting, approval gates, and redacted summaries.'
    PowerShellVersion    = '7.0'
    CompatiblePSEditions = @('Core')
    FunctionsToExport    = @(
        'Invoke-LegionJob'
        'New-LegionPlan'
        'Approve-LegionJob'
        'Get-LegionPlaybook'
        'Get-LegionJob'
        'Export-LegionSummary'
    )
    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = @()
    PrivateData          = @{
        PSData = @{
            Tags         = @('Remoting', 'Automation', 'AI', 'Playbooks', 'Security', 'Parallel')
            LicenseUri   = 'https://opensource.org/licenses/MIT'
            ProjectUri   = 'https://github.com/btstevens1984az/LegionPS'
            ReleaseNotes = 'Initial 0.1.0 release: parallel fan-out, allowlisted playbooks, approval mode, simulation, redacted export.'
        }
    }
}
