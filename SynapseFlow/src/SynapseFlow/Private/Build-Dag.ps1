function Build-Dag {
    <#
    .SYNOPSIS
        Builds a JSON-serializable DAG of stages from an intent heuristic or explicit stage list.
    #>
    [CmdletBinding()]
    param(
        [string]$Intent,

        [hashtable[]]$Stages,

        [string[]]$Targets = @('web-01', 'db-02'),

        [string]$PlanId
    )

    if (-not $PlanId) {
        $PlanId = [guid]::NewGuid().ToString()
    }

    $meta = Get-SynapseCatalogMeta
    $resolved = [System.Collections.Generic.List[hashtable]]::new()

    if ($Stages -and $Stages.Count -gt 0) {
        $index = 0
        foreach ($s in $Stages) {
            $name = if ($s.ContainsKey('Name')) { [string]$s.Name } else { [string]$s.Stage }
            if ([string]::IsNullOrWhiteSpace($name)) {
                throw "Explicit stage at index $index is missing Name/Stage."
            }
            Assert-StageCatalog -StageName $name | Out-Null

            $deps = @()
            if ($s.ContainsKey('DependsOn') -and $null -ne $s.DependsOn) {
                $deps = @($s.DependsOn)
            }

            $stageTargets = $Targets
            if ($s.ContainsKey('Targets') -and $null -ne $s.Targets) {
                $stageTargets = @($s.Targets)
            }

            $resolved.Add(@{
                Id           = "stage-$index"
                Name         = $name
                DependsOn    = $deps
                Targets      = @($stageTargets)
                Destructive  = [bool]$meta[$name].Destructive
                Status       = 'Pending'
                Result       = $null
                Error        = $null
            })
            $index++
        }
    }
    else {
        if ([string]::IsNullOrWhiteSpace($Intent)) {
            throw 'Provide -Intent or -Stages.'
        }

        $intentLower = $Intent.ToLowerInvariant()
        $matched = [System.Collections.Generic.List[string]]::new()

        foreach ($entry in $meta.GetEnumerator()) {
            foreach ($kw in $entry.Value.Keywords) {
                if ($intentLower.Contains($kw)) {
                    if ($entry.Key -notin $matched) {
                        $matched.Add($entry.Key)
                    }
                    break
                }
            }
        }

        # Default pipeline when intent is vague but actionable
        if ($matched.Count -eq 0) {
            $matched.Add('Discover-Services')
            $matched.Add('Verify-Health')
        }

        # Prefer a sensible order: discover → mutate → verify
        $preferredOrder = @('Discover-Services', 'Restart-Spooler', 'Verify-Health')
        $ordered = @($preferredOrder | Where-Object { $_ -in $matched })
        # Append any matched stages not in preferred list (future-proof)
        foreach ($m in $matched) {
            if ($m -notin $ordered) { $ordered += $m }
        }

        for ($i = 0; $i -lt $ordered.Count; $i++) {
            $name = $ordered[$i]
            $deps = @()
            if ($i -gt 0) {
                $deps = @("stage-$($i - 1)")
            }
            $resolved.Add(@{
                Id           = "stage-$i"
                Name         = $name
                DependsOn    = $deps
                Targets      = @($Targets)
                Destructive  = [bool]$meta[$name].Destructive
                Status       = 'Pending'
                Result       = $null
                Error        = $null
            })
        }
    }

    # Validate dependency edges reference known stage IDs
    $ids = @($resolved | ForEach-Object { $_.Id })
    foreach ($stage in $resolved) {
        foreach ($dep in $stage.DependsOn) {
            if ($dep -notin $ids) {
                throw "Stage '$($stage.Id)' DependsOn unknown id '$dep'."
            }
        }
    }

    $plan = [ordered]@{
        PlanId             = $PlanId
        Intent             = $Intent
        CreatedAtUtc       = [datetime]::UtcNow.ToString('o')
        Reviewed           = $false
        DestructiveApproved = $false
        Status             = 'Draft'
        Targets            = @($Targets)
        Stages             = @($resolved.ToArray())
        Version            = '0.1.0'
    }

    return [pscustomobject]$plan
}
