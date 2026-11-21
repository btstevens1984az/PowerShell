function Export-LegionSummary {
    <#
    .SYNOPSIS
        Exports a redacted JSON summary of a Legion job suitable for sharing or LLM context.
    .DESCRIPTION
        Hostnames are partially redacted and obvious secret patterns are stripped before export.
    .EXAMPLE
        Export-LegionSummary -JobId $job.JobId -Path ./summary.json
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [string]$JobId,

        [Parameter()]
        [string]$Path,

        [Parameter()]
        [switch]$PassThru
    )

    process {
        $job = Get-LegionJob -JobId $JobId
        $redacted = Redact-Result -InputObject $job

        $summary = [pscustomobject]@{
            ExportedAt    = [datetime]::UtcNow.ToString('o')
            SchemaVersion = '1.0'
            Redacted      = $true
            Job           = $redacted
        }

        $json = $summary | ConvertTo-Json -Depth 10

        if ($Path) {
            $dir = Split-Path -Parent $Path
            if ($dir -and -not (Test-Path -LiteralPath $dir)) {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
            }
            Set-Content -LiteralPath $Path -Value $json -Encoding utf8
            Write-Verbose "Wrote redacted summary to $Path"
        }

        if ($PassThru -or -not $Path) {
            return $json
        }
    }
}
