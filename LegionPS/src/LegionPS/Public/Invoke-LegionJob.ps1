function Invoke-LegionJob {
    <#
    .SYNOPSIS
        Fan out an allowlisted playbook to many targets in parallel.
    .DESCRIPTION
        Resolves the playbook from the Playbooks allowlist, builds a signed job pack,
        optionally gates on approval, then runs parallel remoting (or Simulation mocks).
    .PARAMETER Playbook
        Playbook name (e.g. Restart-Spooler) or path inside Playbooks/.
    .PARAMETER Targets
        Fictional or real computer names to target (examples: web-01, db-02, app-03).
    .PARAMETER Parameters
        Hashtable of parameters passed into the playbook.
    .PARAMETER ThrottleLimit
        Max concurrent workers (default 8).
    .PARAMETER DryRun
        Plan only — do not execute.
    .PARAMETER ApprovalMode
        None (run immediately) or Required (must Approve-LegionJob first).
    .PARAMETER Simulation
        Mock remoting offline so demos work without network.
    .PARAMETER JobId
        Resume/execute a previously created job that is Ready or Approved.
    .PARAMETER UseHmac
        Also HMAC-sign playbook content with an ephemeral TEMP key.
    .EXAMPLE
        Invoke-LegionJob -Playbook Restart-Spooler -Targets web-01,app-03 -Simulation
    #>
    [CmdletBinding(DefaultParameterSetName = 'New')]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory, ParameterSetName = 'New')]
        [string]$Playbook,

        [Parameter(Mandatory, ParameterSetName = 'New')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Targets,

        [Parameter(ParameterSetName = 'New')]
        [hashtable]$Parameters = @{},

        [Parameter(ParameterSetName = 'New')]
        [Parameter(ParameterSetName = 'Existing')]
        [ValidateRange(1, 256)]
        [int]$ThrottleLimit = 8,

        [Parameter(ParameterSetName = 'New')]
        [Parameter(ParameterSetName = 'Existing')]
        [switch]$DryRun,

        [Parameter(ParameterSetName = 'New')]
        [ValidateSet('None', 'Required')]
        [string]$ApprovalMode = 'None',

        [Parameter(ParameterSetName = 'New')]
        [Parameter(ParameterSetName = 'Existing')]
        [switch]$Simulation,

        [Parameter(Mandatory, ParameterSetName = 'Existing')]
        [string]$JobId,

        [Parameter(ParameterSetName = 'New')]
        [switch]$UseHmac
    )

    if ($PSCmdlet.ParameterSetName -eq 'Existing') {
        $job = $null
        if (-not $script:LegionJobStore.TryGetValue($JobId, [ref]$job)) {
            throw "Job not found: $JobId"
        }
        if ($job.Status -eq 'PendingApproval' -or -not $job.Approved) {
            throw "Job $JobId requires approval. Run Approve-LegionJob -JobId $JobId first."
        }
        if ($job.Status -eq 'Completed') {
            Write-Warning "Job $JobId already completed; returning stored results."
            return $job
        }

        $playbookFile = Assert-Allowlist -Playbook $job.PlaybookPath
        $job.Status = 'Running'
        $script:LegionJobStore[$JobId] = $job

        $runResults = Invoke-ParallelFanOut -Targets $job.Targets -PlaybookFile $playbookFile `
            -Parameters $job.Parameters -ThrottleLimit $ThrottleLimit -DryRun:$DryRun -Simulation:$Simulation

        $job.Results = @($runResults)
        $job.Status = 'Completed'
        $job.FinishedAt = [datetime]::UtcNow
        $script:LegionJobStore[$JobId] = $job
        return $job
    }

    $playbookFile = Assert-Allowlist -Playbook $Playbook
    $job = New-JobPack -PlaybookFile $playbookFile -Targets $Targets -Parameters $Parameters `
        -ApprovalMode $ApprovalMode -UseHmac:$UseHmac

    $script:LegionJobStore[$job.JobId] = $job

    if ($ApprovalMode -eq 'Required') {
        Write-Verbose "Job $($job.JobId) pending approval."
        return $job
    }

    $job.Status = 'Running'
    $script:LegionJobStore[$job.JobId] = $job

    $runResults = Invoke-ParallelFanOut -Targets $Targets -PlaybookFile $playbookFile `
        -Parameters $Parameters -ThrottleLimit $ThrottleLimit -DryRun:$DryRun -Simulation:$Simulation

    $job.Results = @($runResults)
    $job.Status = 'Completed'
    $job.FinishedAt = [datetime]::UtcNow
    $script:LegionJobStore[$job.JobId] = $job
    return $job
}
