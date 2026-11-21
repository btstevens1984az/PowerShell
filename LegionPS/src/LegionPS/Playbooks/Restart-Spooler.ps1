<#
.SYNOPSIS
    Restarts the Print Spooler service on a target (demo playbook).
.PARAMETER ComputerName
    Target computer name (example: web-01).
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$ComputerName
)

# Demo-safe playbook body. Live remoting would use Invoke-Command / CIM.
# When Simulation is enabled, Invoke-ParallelFanOut never reaches this path.

$result = [pscustomobject]@{
    ComputerName = $ComputerName
    Service      = 'Spooler'
    Action       = 'Restart'
    Status       = 'Succeeded'
    Message      = "Spooler restart requested on $ComputerName"
    Timestamp    = [datetime]::UtcNow
}

return $result
