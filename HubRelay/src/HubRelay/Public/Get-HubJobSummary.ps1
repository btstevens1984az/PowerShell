function Get-HubJobSummary {
    <#
    .SYNOPSIS
        Returns a redacted summary of a HubRelay job suitable for LLM consumption.
    .PARAMETER Id
        Job id.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Id
    )

    $job = Get-HubJob -Id $Id

    $summary = [ordered]@{
        Id          = $job.Id
        Playbook    = $job.Playbook
        Status      = $job.Status
        DryRun      = $job.DryRun
        Simulation  = $job.Simulation
        CreatedAt   = $job.CreatedAt
        StartedAt   = $job.StartedAt
        CompletedAt = $job.CompletedAt
        TargetCount = if ($job.Targets) { @($job.Targets).Count } else { $script:HubRelayState.SimulatedFleet.Count }
        Error       = $job.Error
        Result      = $null
    }

    if ($null -ne $job.Result) {
        $summary.Result = Redact-Summary -InputObject $job.Result
    }

    if ($null -ne $summary.Error) {
        $summary.Error = Redact-Summary -InputObject ([string]$summary.Error)
    }

    return [pscustomobject]$summary
}
