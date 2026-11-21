function Get-SynapseFlow {
    <#
    .SYNOPSIS
        Retrieves a running or completed SynapseFlow by FlowId, or lists all session flows.
    .EXAMPLE
        Get-SynapseFlow -FlowId $flow.FlowId
    .EXAMPLE
        Get-SynapseFlow
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Position = 0)]
        [string]$FlowId
    )

    if ($FlowId) {
        $found = $null
        if (-not $script:SynapseFlowRegistry.TryGetValue($FlowId, [ref]$found)) {
            throw "FlowId not found in session registry: $FlowId"
        }
        return $found
    }

    return @($script:SynapseFlowRegistry.Values | Sort-Object StartedAtUtc)
}
