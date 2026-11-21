function Redact-Artifact {
    <#
    .SYNOPSIS
        Redacts sensitive patterns from stage artifacts before export or display.
    .NOTES
        Strips emails, home paths, UNC user paths, and common secret key shapes.
        Never persists real inventory — callers should only pass fictional targets.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowNull()]
        [object]$InputObject
    )

    process {
        if ($null -eq $InputObject) {
            return $null
        }

        $text = if ($InputObject -is [string]) {
            $InputObject
        }
        else {
            ($InputObject | ConvertTo-Json -Depth 8 -Compress)
        }

        # Email addresses
        $text = [regex]::Replace($text, '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}', '[REDACTED-EMAIL]')

        # Unix/mac home paths
        $text = [regex]::Replace($text, '(?i)(/Users/|/home/)[A-Za-z0-9._-]+', '[REDACTED-HOME]')

        # Windows user profile paths
        $text = [regex]::Replace($text, '(?i)([A-Z]:\\Users\\)[A-Za-z0-9._-]+', '[REDACTED-HOME]')

        # Common secret-ish key=value fragments
        $text = [regex]::Replace(
            $text,
            '(?i)(api[_-]?key|secret|password|token|connectionstring)\s*[=:]\s*["'']?[^\s"'',;]+',
            '$1=[REDACTED]'
        )

        return $text
    }
}
