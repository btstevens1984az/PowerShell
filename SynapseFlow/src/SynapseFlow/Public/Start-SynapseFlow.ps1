function Start-SynapseFlow {
    <#
    .SYNOPSIS
        Executes a reviewed plan: ready stages run in parallel up to MaxParallelStages.
    .PARAMETER Plan
        Reviewed plan from Confirm-SynapsePlan.
    .PARAMETER MaxParallelStages
        Concurrency cap for ready stages in each DAG wave. Default 2.
    .PARAMETER Simulation
        When set, catalog stages run in Simulation mode (no live side effects).
    .PARAMETER PassThru
        Return the flow record (default).
    .EXAMPLE
        $flow = Start-SynapseFlow -Plan $reviewed -MaxParallelStages 2 -Simulation
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [pscustomobject]$Plan,

        [ValidateRange(1, 64)]
        [int]$MaxParallelStages = 2,

        [switch]$Simulation,

        [switch]$PassThru
    )

    process {
        if (-not $Plan.Reviewed) {
            throw 'Plan must be Reviewed before start. Pipe through Confirm-SynapsePlan first.'
        }

        $destructive = @($Plan.Stages | Where-Object { $_.Destructive -eq $true })
        if ($destructive.Count -gt 0 -and -not $Plan.DestructiveApproved) {
            throw 'Destructive stages present but not approved. Use Confirm-SynapsePlan -ApproveDestructive.'
        }

        Assert-StageCatalog -StageName @($Plan.Stages | ForEach-Object { $_.Name }) | Out-Null

        # Deep-ish copy of stage state for this run
        $runPlan = $Plan | ConvertTo-Json -Depth 10 | ConvertFrom-Json
        foreach ($s in $runPlan.Stages) {
            $s.Status = 'Pending'
            $s.Result = $null
            $s.Error  = $null
        }

        $flowId = [guid]::NewGuid().ToString()
        $flow = [pscustomobject]@{
            FlowId           = $flowId
            PlanId           = $runPlan.PlanId
            Intent           = $runPlan.Intent
            Status           = 'Running'
            Simulation       = [bool]$Simulation
            MaxParallelStages = $MaxParallelStages
            StartedAtUtc     = [datetime]::UtcNow.ToString('o')
            CompletedAtUtc   = $null
            Plan             = $runPlan
        }

        $script:SynapseFlowRegistry[$flowId] = $flow

        try {
            $updated = Invoke-StageParallel -Plan $runPlan -MaxParallelStages $MaxParallelStages -Simulation:$Simulation
            $flow.Plan = $updated
            $flow.Status = $updated.Status
        }
        catch {
            $flow.Status = 'Failed'
            $flow | Add-Member -NotePropertyName Error -NotePropertyValue $_.Exception.Message -Force
            throw
        }
        finally {
            $flow.CompletedAtUtc = [datetime]::UtcNow.ToString('o')
            $script:SynapseFlowRegistry[$flowId] = $flow
        }

        if ($PassThru -or $true) {
            return $flow
        }
    }
}
