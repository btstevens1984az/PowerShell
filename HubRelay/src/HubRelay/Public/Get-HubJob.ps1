function Get-HubJob {
    <#
    .SYNOPSIS
        Retrieves one HubRelay job or lists recent jobs.
    .PARAMETER Id
        Job id (32-char hex GUID without dashes).
    .PARAMETER Limit
        When Id is omitted, return up to this many recent jobs (newest first).
    #>
    [CmdletBinding()]
    param(
        [string] $Id,

        [ValidateRange(1, 500)]
        [int] $Limit = 50
    )

    if ($PSBoundParameters.ContainsKey('Id') -and -not [string]::IsNullOrWhiteSpace($Id)) {
        $job = $null
        if ($script:HubRelayState.Jobs.TryGetValue($Id, [ref]$job)) {
            return $job
        }
        throw "Job not found: $Id"
    }

    return @(
        $script:HubRelayState.Jobs.Values |
            Sort-Object CreatedAt -Descending |
            Select-Object -First $Limit
    )
}
