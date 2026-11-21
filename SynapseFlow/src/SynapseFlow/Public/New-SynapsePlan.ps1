function New-SynapsePlan {
    <#
    .SYNOPSIS
        Compiles a JSON-serializable DAG of stages from an intent heuristic or explicit stages.
    .DESCRIPTION
        Maps natural-language intent keywords to Catalog allowlist stages, or accepts -Stages
        from an LLM / caller. Targets default to fictional hosts web-01 and db-02.
    .PARAMETER Intent
        Natural-language goal, e.g. "discover services then verify health on web tier".
    .PARAMETER Stages
        Explicit stage hashtables: @{ Name = 'Discover-Services'; DependsOn = @(); Targets = @('web-01') }.
    .PARAMETER Targets
        Fictional host names for stage fanout. Defaults: web-01, db-02.
    .EXAMPLE
        New-SynapsePlan -Intent 'restart spooler and verify health' -Targets web-01,db-02
    .EXAMPLE
        New-SynapsePlan -Stages @{ Name = 'Discover-Services' }, @{ Name = 'Verify-Health'; DependsOn = @('stage-0') }
    #>
    [CmdletBinding(DefaultParameterSetName = 'Intent')]
    [OutputType([pscustomobject])]
    param(
        [Parameter(ParameterSetName = 'Intent', Mandatory, Position = 0)]
        [string]$Intent,

        [Parameter(ParameterSetName = 'Stages', Mandatory)]
        [hashtable[]]$Stages,

        [Parameter()]
        [string[]]$Targets = @('web-01', 'db-02')
    )

    $plan = if ($PSCmdlet.ParameterSetName -eq 'Stages') {
        Build-Dag -Stages $Stages -Targets $Targets
    }
    else {
        Build-Dag -Intent $Intent -Targets $Targets
    }

    # Ensure stage names are allowlisted
    Assert-StageCatalog -StageName @($plan.Stages | ForEach-Object { $_.Name }) | Out-Null

    return $plan
}
