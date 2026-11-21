function Invoke-StageParallel {
    <#
    .SYNOPSIS
        Executes ready DAG stages in parallel up to MaxParallelStages.
        Each stage may Simulation-fanout across Targets.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$Plan,

        [int]$MaxParallelStages = 2,

        [switch]$Simulation
    )

    if ($MaxParallelStages -lt 1) {
        throw 'MaxParallelStages must be >= 1.'
    }

    $stages = @($Plan.Stages)
    $byId = @{}
    foreach ($s in $stages) {
        $byId[$s.Id] = $s
    }

    $moduleRoot = $PSScriptRoot
    if ((Split-Path $moduleRoot -Leaf) -eq 'Private') {
        $moduleRoot = Split-Path $moduleRoot -Parent
    }

    function Get-ReadyStages {
        param($All, $Index)
        $ready = [System.Collections.Generic.List[object]]::new()
        foreach ($s in $All) {
            if ($s.Status -ne 'Pending') { continue }
            $depsOk = $true
            foreach ($dep in @($s.DependsOn)) {
                $parent = $Index[$dep]
                if ($null -eq $parent -or $parent.Status -ne 'Succeeded') {
                    $depsOk = $false
                    break
                }
            }
            if ($depsOk) { [void]$ready.Add($s) }
        }
        return @($ready)
    }

    $Plan.Status = 'Running'
    $safety = 0
    $maxLoops = [Math]::Max(50, $stages.Count * 5)

    while ($true) {
        $safety++
        if ($safety -gt $maxLoops) {
            throw 'Stage scheduler exceeded safety loop limit (possible cyclic DependsOn).'
        }

        $pending = @($stages | Where-Object { $_.Status -eq 'Pending' })
        if ($pending.Count -eq 0) { break }

        $ready = @(Get-ReadyStages -All $stages -Index $byId)
        if ($ready.Count -eq 0) {
            foreach ($p in $pending) {
                $p.Status = 'Skipped'
                $p.Error  = 'Blocked by upstream failure or unmet dependency.'
            }
            break
        }

        $batch = @($ready | Select-Object -First $MaxParallelStages)
        foreach ($b in $batch) { $b.Status = 'Running' }

        $poolSize = [Math]::Min($MaxParallelStages, $batch.Count)
        $pool = [runspacefactory]::CreateRunspacePool(1, $poolSize)
        $pool.Open()

        $handles = @()
        foreach ($b in $batch) {
            $ps = [powershell]::Create()
            $ps.RunspacePool = $pool
            [void]$ps.AddScript({
                param($ModuleRoot, $StageName, $StageId, $Targets, $Sim)
                $ErrorActionPreference = 'Stop'
                . (Join-Path $ModuleRoot 'Private/Assert-StageCatalog.ps1')
                Get-ChildItem (Join-Path $ModuleRoot 'Catalog') -Filter '*.ps1' |
                    ForEach-Object { . $_.FullName }
                Assert-StageCatalog -StageName $StageName | Out-Null
                $results = @()
                foreach ($t in $Targets) {
                    $out = & $StageName -Target $t -Simulation:$Sim
                    $results += @{ Target = $t; Output = $out }
                }
                return @{
                    StageId = $StageId
                    Name    = $StageName
                    Targets = $results
                }
            }).AddArgument($moduleRoot).
              AddArgument($b.Name).
              AddArgument($b.Id).
              AddArgument(@($b.Targets)).
              AddArgument([bool]$Simulation)

            $handles += [pscustomobject]@{
                PowerShell = $ps
                Handle     = $ps.BeginInvoke()
                Stage      = $b
            }
        }

        foreach ($h in $handles) {
            try {
                $result = $h.PowerShell.EndInvoke($h.Handle)
                if ($h.PowerShell.HadErrors) {
                    $errMsg = ($h.PowerShell.Streams.Error | ForEach-Object { $_.ToString() }) -join '; '
                    $h.Stage.Status = 'Failed'
                    $h.Stage.Error  = if ($errMsg) { $errMsg } else { 'Stage failed.' }
                    $h.Stage.Result = $null
                }
                else {
                    $payload = if ($result -is [System.Collections.IList] -and $result.Count -gt 0) {
                        $result[0]
                    }
                    else {
                        $result
                    }
                    $h.Stage.Status = 'Succeeded'
                    $h.Stage.Result = $payload
                    $h.Stage.Error  = $null
                }
            }
            catch {
                $h.Stage.Status = 'Failed'
                $h.Stage.Error  = $_.Exception.Message
                $h.Stage.Result = $null
            }
            finally {
                $h.PowerShell.Dispose()
            }
        }

        $pool.Close()
        $pool.Dispose()
    }

    $failed = @($stages | Where-Object { $_.Status -eq 'Failed' })
    $Plan.Status = if ($failed.Count -gt 0) { 'Failed' } else { 'Succeeded' }
    return $Plan
}
