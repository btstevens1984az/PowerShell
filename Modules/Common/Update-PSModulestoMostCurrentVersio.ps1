# Purpose: Update-PSModulestoMostCurrentVersio — Reusable PowerShell function libraries.
Function Update-PSModulestoMostCurrentVersion {
Get-Module -ListAvailable |
Where-Object ModuleBase -like $env:ProgramFiles\WindowsPowerShell\Modules\* |
Sort-Object -Property Name, Version -Descending |
Get-Unique -PipelineVariable Module |
ForEach-Object {
    if (-not(Test-Path -Path "$($_.ModuleBase)\PSGetModuleInfo.xml")) {
        Find-Module -Name $_.Name -OutVariable Repo -ErrorAction SilentlyContinue |
        Compare-Object -ReferenceObject $_ -Property Name, Version |
        Where-Object SideIndicator -eq '=>' |
        Select-Object -Property Name,
                                Version,
                                @{label='Repository';expression={$Repo.Repository}},
                                @{label='InstalledVersion';expression={$Module.Version}}
    }
} | ForEach-Object {Install-Module -Name $_.Name -Force}
}