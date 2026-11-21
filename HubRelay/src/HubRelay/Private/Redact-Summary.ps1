function Redact-Summary {
    <#
    .SYNOPSIS
        Redacts secrets and sensitive patterns from job result summaries.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        $InputObject
    )

    $patterns = @(
        @{ Pattern = '(?i)(bearer\s+)[A-Za-z0-9\-._~+/]+=*'; Replacement = '${1}[REDACTED]' }
        @{ Pattern = '(?i)(token["''\s:=]+)[A-Za-z0-9\-._~+/]+=*'; Replacement = '${1}[REDACTED]' }
        @{ Pattern = '(?i)(password["''\s:=]+)\S+'; Replacement = '${1}[REDACTED]' }
        @{ Pattern = '(?i)(api[_-]?key["''\s:=]+)\S+'; Replacement = '${1}[REDACTED]' }
        @{ Pattern = '(?i)(secret["''\s:=]+)\S+'; Replacement = '${1}[REDACTED]' }
        @{ Pattern = '(?i)[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}'; Replacement = '[REDACTED-EMAIL]' }
        @{ Pattern = '(?i)(/home/|/Users/)[^\s/]+'; Replacement = '${1}[REDACTED-USER]' }
    )

    function ConvertTo-RedactedString {
        param([string] $Text)
        if ([string]::IsNullOrEmpty($Text)) { return $Text }
        $out = $Text
        foreach ($p in $patterns) {
            $out = [regex]::Replace($out, $p.Pattern, $p.Replacement)
        }
        return $out
    }

    if ($null -eq $InputObject) { return $null }

    if ($InputObject -is [string]) {
        return (ConvertTo-RedactedString -Text $InputObject)
    }

    $json = $InputObject | ConvertTo-Json -Depth 8 -Compress
    $redacted = ConvertTo-RedactedString -Text $json
    try {
        return ($redacted | ConvertFrom-Json -AsHashtable)
    }
    catch {
        return $redacted
    }
}
