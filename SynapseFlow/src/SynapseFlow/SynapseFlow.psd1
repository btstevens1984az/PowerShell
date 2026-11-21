@{
    RootModule           = 'SynapseFlow.psm1'
    ModuleVersion        = '0.1.0'
    GUID                 = 'b473b040-c4b3-4334-8eda-f6789a45faa3'
    Author               = 'SynapseFlow Contributors'
    CompanyName          = 'SynapseFlow'
    Copyright            = '(c) 2026 SynapseFlow Contributors. MIT License.'
    Description          = 'Intent-driven parallel orchestration: compile natural-language intents into DAG stage plans, review, execute in parallel, and replan failed branches. Catalog allowlist only. No telemetry.'
    PowerShellVersion    = '7.0'
    CompatiblePSEditions = @('Core')
    FunctionsToExport    = @(
        'New-SynapsePlan'
        'Confirm-SynapsePlan'
        'Start-SynapseFlow'
        'Get-SynapseFlow'
        'Repair-SynapseFlow'
        'Export-SynapseReport'
    )
    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = @()
    PrivateData          = @{
        PSData = @{
            Tags         = @('Orchestration', 'DAG', 'Automation', 'Parallel', 'Intent', 'PowerShell7')
            LicenseUri   = 'https://github.com/btstevens1984az/SynapseFlow/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/btstevens1984az/SynapseFlow'
            ReleaseNotes = 'Initial 0.1.0 release: intent heuristic planner, review gate, parallel stage runner, replan, catalog allowlist.'
        }
    }
}
