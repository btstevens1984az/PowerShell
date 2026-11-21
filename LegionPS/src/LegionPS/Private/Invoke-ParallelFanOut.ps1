function Invoke-ParallelFanOut {
    <#
    .SYNOPSIS
        Runs a playbook script against many targets with a throttle limit.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [string[]]$Targets,

        [Parameter(Mandatory)]
        [System.IO.FileInfo]$PlaybookFile,

        [Parameter()]
        [hashtable]$Parameters = @{},

        [Parameter()]
        [ValidateRange(1, 256)]
        [int]$ThrottleLimit = 8,

        [Parameter()]
        [switch]$DryRun,

        [Parameter()]
        [switch]$Simulation
    )

    $playbookPath = $PlaybookFile.FullName
    $playbookName = $PlaybookFile.BaseName
    $results = [System.Collections.Concurrent.ConcurrentBag[object]]::new()

    if ($DryRun) {
        foreach ($target in $Targets) {
            $results.Add([pscustomobject]@{
                    Target     = $target
                    Playbook   = $playbookName
                    Status     = 'DryRun'
                    Output     = "Would invoke $playbookName on $target"
                    Error      = $null
                    StartedAt  = [datetime]::UtcNow
                    FinishedAt = [datetime]::UtcNow
                    Simulated  = [bool]$Simulation
                })
        }
        return @($results.ToArray())
    }

    $Targets | ForEach-Object -ThrottleLimit $ThrottleLimit -Parallel {
        $target = $_
        $path = $using:playbookPath
        $name = $using:playbookName
        $params = $using:Parameters
        $simulate = $using:Simulation
        $bag = $using:results
        $started = [datetime]::UtcNow

        try {
            if ($simulate) {
                # Offline mock remoting — no network, fictional host outcomes.
                $mock = & {
                    param($t, $n, $p)
                    [pscustomobject]@{
                        ComputerName = $t
                        Playbook     = $n
                        Result       = "Simulated success for $n"
                        Parameters   = $p
                        Healthy      = $true
                    }
                } -t $target -n $name -p $params

                $bag.Add([pscustomobject]@{
                        Target     = $target
                        Playbook   = $name
                        Status     = 'Succeeded'
                        Output     = $mock
                        Error      = $null
                        StartedAt  = $started
                        FinishedAt = [datetime]::UtcNow
                        Simulated  = $true
                    })
            }
            else {
                $scriptContent = Get-Content -LiteralPath $path -Raw
                $output = & ([scriptblock]::Create($scriptContent)) -ComputerName $target @params
                $bag.Add([pscustomobject]@{
                        Target     = $target
                        Playbook   = $name
                        Status     = 'Succeeded'
                        Output     = $output
                        Error      = $null
                        StartedAt  = $started
                        FinishedAt = [datetime]::UtcNow
                        Simulated  = $false
                    })
            }
        }
        catch {
            $bag.Add([pscustomobject]@{
                    Target     = $target
                    Playbook   = $name
                    Status     = 'Failed'
                    Output     = $null
                    Error      = $_.Exception.Message
                    StartedAt  = $started
                    FinishedAt = [datetime]::UtcNow
                    Simulated  = [bool]$simulate
                })
        }
    }

    return @($results.ToArray() | Sort-Object Target)
}
