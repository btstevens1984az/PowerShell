function Get-LegionPlaybook {
    <#
    .SYNOPSIS
        Lists allowlisted playbooks available under Playbooks/.
    .EXAMPLE
        Get-LegionPlaybook
    .EXAMPLE
        Get-LegionPlaybook -Name Restart-Spooler
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter()]
        [string]$Name
    )

    $files = Get-ChildItem -LiteralPath $script:LegionPlaybooksPath -Filter '*.ps1' -File |
        Sort-Object Name

    if ($Name) {
        $needle = if ($Name.EndsWith('.ps1', [System.StringComparison]::OrdinalIgnoreCase)) {
            $Name
        }
        else {
            "$Name.ps1"
        }
        $files = $files | Where-Object { $_.Name -eq $needle }
        if (-not $files) {
            throw "Playbook not found in allowlist: $Name"
        }
    }

    foreach ($file in $files) {
        $help = $null
        try {
            $help = Get-Help -Name $file.FullName -ErrorAction SilentlyContinue
        }
        catch {
            $help = $null
        }

        [pscustomobject]@{
            Name        = $file.BaseName
            Path        = $file.FullName
            Length      = $file.Length
            Synopsis    = if ($help) { [string]$help.Synopsis } else { '' }
            Allowlisted = $true
        }
    }
}
