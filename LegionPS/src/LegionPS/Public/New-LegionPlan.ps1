function New-LegionPlan {
    <#
    .SYNOPSIS
        Creates a JSON-serializable plan object for LLM produce/consume workflows.
    .DESCRIPTION
        Plans describe intended playbook runs without executing them. An LLM can emit
        this shape; operators review and then Invoke-LegionJob / Approve-LegionJob.
    .EXAMPLE
        New-LegionPlan -Playbook Get-ServiceHealth -Targets web-01,db-02 -Rationale 'Health check before deploy'
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [string]$Playbook,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Targets,

        [Parameter()]
        [hashtable]$Parameters = @{},

        [Parameter()]
        [ValidateSet('None', 'Required')]
        [string]$ApprovalMode = 'Required',

        [Parameter()]
        [ValidateRange(1, 256)]
        [int]$ThrottleLimit = 8,

        [Parameter()]
        [string]$Rationale = '',

        [Parameter()]
        [string]$RequestedBy = 'operator',

        [Parameter()]
        [ValidateSet('low', 'medium', 'high')]
        [string]$Risk = 'medium'
    )

    $playbookFile = Assert-Allowlist -Playbook $Playbook

    $plan = [pscustomobject]@{
        PSTypeName    = 'LegionPS.Plan'
        SchemaVersion = '1.0'
        PlanId        = [guid]::NewGuid().ToString('N')
        CreatedAt     = [datetime]::UtcNow.ToString('o')
        RequestedBy   = $RequestedBy
        Rationale     = $Rationale
        Risk          = $Risk
        Playbook      = $playbookFile.BaseName
        Targets       = @($Targets)
        Parameters    = $Parameters
        ApprovalMode  = $ApprovalMode
        ThrottleLimit = $ThrottleLimit
        DryRunDefault = $true
        SimulationOk  = $true
        Notes         = 'Review before Invoke-LegionJob. Prefer -DryRun then -Simulation before live remoting.'
    }

    return $plan
}
