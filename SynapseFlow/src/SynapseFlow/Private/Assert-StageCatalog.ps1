function Assert-StageCatalog {
    <#
    .SYNOPSIS
        Validates stage names against the built-in Catalog allowlist.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$StageName
    )

    $allowed = @(
        'Discover-Services'
        'Restart-Spooler'
        'Verify-Health'
    )

    $invalid = @($StageName | Where-Object { $_ -notin $allowed } | Select-Object -Unique)
    if ($invalid.Count -gt 0) {
        $list = $invalid -join ', '
        throw "Stage(s) not in Catalog allowlist: $list. Allowed: $($allowed -join ', ')."
    }

    return $true
}

function Get-SynapseCatalogMeta {
    <#
    .SYNOPSIS
        Returns metadata for Catalog stages (destructive flag, summary).
    #>
    [CmdletBinding()]
    param()

    return @{
        'Discover-Services' = @{
            Destructive = $false
            Summary     = 'Enumerate listening services / roles on target hosts (simulation-safe).'
            Keywords    = @('discover', 'inventory', 'list', 'services', 'enum', 'scan')
        }
        'Restart-Spooler' = @{
            Destructive = $true
            Summary     = 'Restart the print spooler service on targets (destructive).'
            Keywords    = @('restart', 'spooler', 'print', 'recycle', 'bounce')
        }
        'Verify-Health' = @{
            Destructive = $false
            Summary     = 'Verify host health signals after prior stages.'
            Keywords    = @('verify', 'health', 'check', 'validate', 'status', 'probe')
        }
    }
}
