function Get-LegionJob {
    <#
    .SYNOPSIS
        Retrieves stored Legion jobs by Id or lists all in-session jobs.
    .EXAMPLE
        Get-LegionJob
        Get-LegionJob -JobId $id
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter()]
        [Alias('Id')]
        [string]$JobId
    )

    if ($JobId) {
        $job = $null
        if (-not $script:LegionJobStore.TryGetValue($JobId, [ref]$job)) {
            throw "Job not found: $JobId"
        }
        return $job
    }

    return @($script:LegionJobStore.Values | Sort-Object CreatedAt)
}
