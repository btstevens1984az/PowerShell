@{
    RootModule           = 'HubRelay.psm1'
    ModuleVersion        = '0.1.0'
    GUID                 = 'A006F641-4E79-4533-9601-A1F91E0338B1'
    Author               = 'HubRelay Contributors'
    CompanyName          = 'HubRelay'
    Copyright            = '(c) 2026 HubRelay Contributors. MIT License.'
    Description          = 'Secure localhost HTTPS-style control-plane endpoint for LLM tool calls. Allowlisted playbooks, bearer auth, rate limiting, and result redaction.'
    PowerShellVersion    = '7.0'
    CompatiblePSEditions = @('Core')
    FunctionsToExport    = @(
        'Start-HubRelay'
        'Stop-HubRelay'
        'New-HubJob'
        'Get-HubJob'
        'Get-HubJobSummary'
        'Test-HubRelay'
    )
    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = @()
    PrivateData          = @{
        PSData = @{
            Tags         = @('LLM', 'Tools', 'ControlPlane', 'HttpListener', 'Automation', 'Security')
            LicenseUri   = 'https://github.com/btstevens1984az/HubRelay/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/btstevens1984az/HubRelay'
            ReleaseNotes = 'Initial 0.1.0 release: localhost listener, allowlisted playbooks, dry-run and simulation modes.'
        }
    }
}
