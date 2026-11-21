function Export-SynapseReport {
    <#
    .SYNOPSIS
        Exports a redacted JSON report for a plan or flow.
    .PARAMETER InputObject
        Plan or Flow object.
    .PARAMETER Path
        Optional file path. When omitted, returns the JSON string.
    .EXAMPLE
        $flow | Export-SynapseReport -Path ./report.json
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [pscustomobject]$InputObject,

        [string]$Path
    )

    process {
        $raw = $InputObject | ConvertTo-Json -Depth 12
        $redacted = Redact-Artifact -InputObject $raw

        # Pretty-print when possible
        try {
            $parsed = $redacted | ConvertFrom-Json
            $json = $parsed | ConvertTo-Json -Depth 12
        }
        catch {
            $json = $redacted
        }

        if ($Path) {
            $dir = Split-Path -Parent $Path
            if ($dir -and -not (Test-Path -LiteralPath $dir)) {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
            }
            Set-Content -LiteralPath $Path -Value $json -Encoding utf8
            return Get-Item -LiteralPath $Path
        }

        return $json
    }
}
