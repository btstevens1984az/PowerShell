function New-HubJob {
    <#
    .SYNOPSIS
        Creates and optionally executes a HubRelay job in-process.
    .DESCRIPTION
        Works without the HTTP listener. Only allowlisted playbooks are accepted.
        Use -DryRun or -Simulation for offline demos.
    .PARAMETER Playbook
        Allowlisted playbook name (Clear-TempSafe or Get-ServiceHealth).
    .PARAMETER Parameters
        Hashtable of playbook parameters (excluding Target, which is set per node).
    .PARAMETER Targets
        Optional fictional host names. Defaults to the built-in simulated fleet.
    .PARAMETER DryRun
        Report intended actions without side effects.
    .PARAMETER Simulation
        Force simulation mode for this job.
    .PARAMETER Wait
        Execute immediately (default). When set to false, marks job as Queued.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Playbook,

        [hashtable] $Parameters = @{},

        [string[]] $Targets,

        [switch] $DryRun,

        [switch] $Simulation,

        [bool] $Wait = $true
    )

    $null = Assert-Allowlist -Playbook $Playbook

    $jobId = [guid]::NewGuid().ToString('n')
    $created = [datetime]::UtcNow

    $job = [ordered]@{
        Id         = $jobId
        Playbook   = [System.IO.Path]::GetFileNameWithoutExtension($Playbook)
        Parameters = $Parameters
        Targets    = $Targets
        DryRun     = [bool]$DryRun -or [bool]$script:HubRelayState.DryRunDefault
        Simulation = [bool]$Simulation -or [bool]$script:HubRelayState.Simulation
        Status     = 'Queued'
        CreatedAt  = $created
        StartedAt  = $null
        CompletedAt = $null
        Result     = $null
        Error      = $null
    }

    if ($Wait) {
        $job.Status = 'Running'
        $job.StartedAt = [datetime]::UtcNow
        try {
            $fanOut = Invoke-WorkerFanOut -PlaybookName $job.Playbook -Parameters $Parameters `
                -Targets $Targets -DryRun:$job.DryRun -Simulation:$job.Simulation
            $job.Result = $fanOut
            $failed = @($fanOut.Results | Where-Object { $_.Status -eq 'Failed' })
            $job.Status = if ($failed.Count -gt 0) { 'CompletedWithErrors' } else { 'Succeeded' }
        }
        catch {
            $job.Status = 'Failed'
            $job.Error = $_.Exception.Message
        }
        finally {
            $job.CompletedAt = [datetime]::UtcNow
        }
    }

    $record = [pscustomobject]$job
    $null = $script:HubRelayState.Jobs.TryAdd($jobId, $record)
    return $record
}
