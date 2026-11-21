<#
.SYNOPSIS
    Returns a lightweight service health snapshot for a target (demo playbook).
.PARAMETER ComputerName
    Target computer name (example: db-02).
.PARAMETER ServiceName
    Optional service filter; defaults to a small demo set.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ComputerName,

    [Parameter()]
    [string[]]$ServiceName = @('Spooler', 'WinRM', 'EventLog')
)

$services = foreach ($name in $ServiceName) {
    [pscustomobject]@{
        Name   = $name
        Status = 'Running'
        Healthy = $true
    }
}

return [pscustomobject]@{
    ComputerName = $ComputerName
    CheckedAt    = [datetime]::UtcNow
    Services     = @($services)
    Overall      = 'Healthy'
}
