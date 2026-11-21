function Invoke-WorkerFanOut {
    <#
    .SYNOPSIS
        Executes an allowlisted playbook against a fictional or simulated fleet.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $PlaybookName,

        [hashtable] $Parameters = @{},

        [string[]] $Targets,

        [switch] $DryRun,

        [switch] $Simulation
    )

    $playbook = Assert-Allowlist -Playbook $PlaybookName
    $fleet = if ($Targets -and $Targets.Count -gt 0) {
        $Targets | ForEach-Object { @{ Name = $_; Role = 'worker'; Region = 'lab-unspecified' } }
    }
    else {
        $script:HubRelayState.SimulatedFleet
    }

    $results = [System.Collections.Generic.List[object]]::new()

    foreach ($node in $fleet) {
        $nodeName = if ($node -is [hashtable] -or $node -is [System.Collections.IDictionary]) {
            [string]$node['Name']
        }
        else {
            [string]$node.Name
        }

        if ($DryRun -or $Simulation -or $script:HubRelayState.Simulation) {
            $results.Add([pscustomobject]@{
                    Target    = $nodeName
                    Playbook  = $playbook.Name
                    Status    = if ($DryRun) { 'DryRun' } else { 'Simulated' }
                    Output    = "Would run $($playbook.Name) on $nodeName"
                    StartedAt = [datetime]::UtcNow
                    EndedAt   = [datetime]::UtcNow
                })
            continue
        }

        $started = [datetime]::UtcNow
        try {
            $output = & $playbook.Path @Parameters -Target $nodeName
            $results.Add([pscustomobject]@{
                    Target    = $nodeName
                    Playbook  = $playbook.Name
                    Status    = 'Succeeded'
                    Output    = $output
                    StartedAt = $started
                    EndedAt   = [datetime]::UtcNow
                })
        }
        catch {
            $results.Add([pscustomobject]@{
                    Target    = $nodeName
                    Playbook  = $playbook.Name
                    Status    = 'Failed'
                    Output    = $_.Exception.Message
                    StartedAt = $started
                    EndedAt   = [datetime]::UtcNow
                })
        }
    }

    return [pscustomobject]@{
        Playbook = $playbook.Name
        DryRun   = [bool]$DryRun
        Results  = $results.ToArray()
    }
}
