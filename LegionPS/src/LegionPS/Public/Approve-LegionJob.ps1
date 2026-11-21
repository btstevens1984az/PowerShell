function Approve-LegionJob {
    <#
    .SYNOPSIS
        Approves a gated Legion job so it can be executed.
    .EXAMPLE
        Approve-LegionJob -JobId $job.JobId -Approver 'ops-lead'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [string]$JobId,

        [Parameter()]
        [string]$Approver = 'operator',

        [Parameter()]
        [string]$Comment = ''
    )

    process {
        $job = $null
        if (-not $script:LegionJobStore.TryGetValue($JobId, [ref]$job)) {
            throw "Job not found: $JobId"
        }

        if ($job.Status -eq 'Completed') {
            Write-Warning "Job $JobId is already completed."
            return $job
        }

        if ($PSCmdlet.ShouldProcess($JobId, 'Approve Legion job')) {
            $job.Approved = $true
            $job.ApprovedAt = [datetime]::UtcNow
            $job.Approver = $Approver
            $job.ApprovalComment = $Comment
            $job.Status = 'Ready'
            $script:LegionJobStore[$JobId] = $job
        }

        return $job
    }
}
