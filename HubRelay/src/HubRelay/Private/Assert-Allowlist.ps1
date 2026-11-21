function Assert-Allowlist {
    <#
    .SYNOPSIS
        Ensures a playbook name is on the HubRelay allowlist.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Playbook
    )

    $name = [System.IO.Path]::GetFileNameWithoutExtension($Playbook)
    if ($name -notin $script:HubRelayState.Allowlist) {
        throw "Playbook '$name' is not allowlisted. Allowed: $($script:HubRelayState.Allowlist -join ', ')"
    }

    $path = Join-Path $script:HubRelayState.PlaybookRoot "$name.ps1"
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Allowlisted playbook file not found: $name.ps1"
    }

    return [pscustomobject]@{
        Name = $name
        Path = $path
    }
}
