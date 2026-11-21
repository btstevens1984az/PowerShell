function Repair-SynapseFlow {
    <#
    .SYNOPSIS
        Regenerates failed branches of a flow into a new Draft plan ready for review.
    .DESCRIPTION
        Failed and skipped stages are rebuilt with the same Catalog names and targets.
        Succeeded upstream stages become DependsOn anchors when present.
    .PARAMETER Flow
        Flow object from Start-SynapseFlow / Get-SynapseFlow.
    .PARAMETER FlowId
        Session FlowId to look up.
    .EXAMPLE
        Repair-SynapseFlow -Flow $flow | Confirm-SynapsePlan -ApproveDestructive
    #>
    [CmdletBinding(DefaultParameterSetName = 'Flow')]
    [OutputType([pscustomobject])]
    param(
        [Parameter(ParameterSetName = 'Flow', Mandatory, ValueFromPipeline)]
        [pscustomobject]$Flow,

        [Parameter(ParameterSetName = 'FlowId', Mandatory)]
        [string]$FlowId
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'FlowId') {
            $Flow = Get-SynapseFlow -FlowId $FlowId
        }

        if (-not $Flow.Plan -or -not $Flow.Plan.Stages) {
            throw 'Flow has no Plan/Stages to replan.'
        }

        $stages = @($Flow.Plan.Stages)
        $failedOrSkipped = @($stages | Where-Object { $_.Status -in @('Failed', 'Skipped') })
        if ($failedOrSkipped.Count -eq 0) {
            throw 'No failed or skipped stages to replan.'
        }

        $succeededIds = @($stages | Where-Object { $_.Status -eq 'Succeeded' } | ForEach-Object { $_.Id })

        $newStages = [System.Collections.Generic.List[hashtable]]::new()
        $index = 0
        foreach ($s in $failedOrSkipped) {
            # Keep edges that still exist among the replan set or succeeded anchors
            $deps = @()
            foreach ($d in @($s.DependsOn)) {
                if ($d -in $succeededIds) {
                    # Already done — no dependency needed in the new plan
                    continue
                }
                $stillFailing = $failedOrSkipped | Where-Object { $_.Id -eq $d }
                if ($stillFailing) {
                    # Map old id to new sequential id later — record old dep for remapping
                    $deps += $d
                }
            }

            $newStages.Add(@{
                Name      = $s.Name
                DependsOn = $deps
                Targets   = @($s.Targets)
                _OldId    = $s.Id
            })
            $index++
        }

        # Remap DependsOn from old ids to new stage-N ids
        $oldToNew = @{}
        for ($i = 0; $i -lt $newStages.Count; $i++) {
            $oldToNew[$newStages[$i]._OldId] = "stage-$i"
        }

        $explicit = @()
        for ($i = 0; $i -lt $newStages.Count; $i++) {
            $ns = $newStages[$i]
            $mappedDeps = @()
            foreach ($d in @($ns.DependsOn)) {
                if ($oldToNew.ContainsKey($d)) {
                    $mappedDeps += $oldToNew[$d]
                }
            }
            $explicit += @{
                Name      = $ns.Name
                DependsOn = $mappedDeps
                Targets   = $ns.Targets
            }
        }

        $intent = if ($Flow.Intent) {
            "Replan of flow $($Flow.FlowId): $($Flow.Intent)"
        }
        else {
            "Replan of flow $($Flow.FlowId)"
        }

        $plan = Build-Dag -Intent $intent -Stages $explicit -Targets @($Flow.Plan.Targets)
        $plan | Add-Member -NotePropertyName ReplannedFromFlowId -NotePropertyValue $Flow.FlowId -Force
        $plan.Status = 'Draft'
        $plan.Reviewed = $false
        $plan.DestructiveApproved = $false

        return $plan
    }
}
