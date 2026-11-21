function Confirm-SynapsePlan {
    <#
    .SYNOPSIS
        Marks a SynapseFlow plan as Reviewed. Destructive stages require -ApproveDestructive.
    .PARAMETER Plan
        Plan object from New-SynapsePlan (pipeline-friendly).
    .PARAMETER ApproveDestructive
        Required when any stage has Destructive = $true (e.g. Restart-Spooler).
    .EXAMPLE
        $plan | Confirm-SynapsePlan -ApproveDestructive
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [pscustomobject]$Plan,

        [switch]$ApproveDestructive
    )

    process {
        if (-not $Plan.Stages) {
            throw 'Plan has no Stages.'
        }

        Assert-StageCatalog -StageName @($Plan.Stages | ForEach-Object { $_.Name }) | Out-Null

        $destructive = @($Plan.Stages | Where-Object { $_.Destructive -eq $true })
        if ($destructive.Count -gt 0 -and -not $ApproveDestructive) {
            $names = ($destructive | ForEach-Object { $_.Name } | Select-Object -Unique) -join ', '
            throw "Plan contains destructive stage(s): $names. Re-run with -ApproveDestructive after human review."
        }

        $Plan.Reviewed = $true
        $Plan.DestructiveApproved = [bool]$ApproveDestructive
        $Plan.Status = 'Reviewed'
        $Plan | Add-Member -NotePropertyName ReviewedAtUtc -NotePropertyValue ([datetime]::UtcNow.ToString('o')) -Force

        return $Plan
    }
}
