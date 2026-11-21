function Redact-Result {
    <#
    .SYNOPSIS
        Partially redacts hostnames and strips obvious secret patterns from job results.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        [object]$InputObject
    )

    function Get-RedactedHostname {
        param([string]$Name)
        if ([string]::IsNullOrWhiteSpace($Name)) { return $Name }
        if ($Name.Length -le 3) { return ('*' * $Name.Length) }
        $keep = [Math]::Min(3, [Math]::Floor($Name.Length / 3))
        return ($Name.Substring(0, $keep) + ('*' * ($Name.Length - $keep)))
    }

    function Get-RedactedText {
        param([string]$Text)
        if ($null -eq $Text) { return $null }

        $patterns = @(
            '(?i)(password|passwd|pwd)\s*[=:]\s*\S+'
            '(?i)(api[_-]?key|secret|token|bearer)\s*[=:]\s*\S+'
            '(?i)(authorization)\s*:\s*bearer\s+\S+'
            '(?i)-----BEGIN [A-Z ]*PRIVATE KEY-----[\s\S]*?-----END [A-Z ]*PRIVATE KEY-----'
            '(?i)(aws_secret_access_key|client_secret)\s*[=:]\s*\S+'
        )

        $redacted = $Text
        foreach ($pattern in $patterns) {
            $redacted = [regex]::Replace($redacted, $pattern, '[REDACTED]')
        }
        return $redacted
    }

    function Test-IsPrimitive {
        param([object]$Value)
        if ($null -eq $Value) { return $true }
        $t = $Value.GetType()
        return (
            $t.IsPrimitive -or
            $Value -is [string] -or
            $Value -is [decimal] -or
            $Value -is [datetime] -or
            $Value -is [guid] -or
            $Value -is [timespan] -or
            $Value -is [enum]
        )
    }

    function Convert-Node {
        param([object]$Node)

        if ($null -eq $Node) { return $null }

        if ($Node -is [string]) {
            return (Get-RedactedText -Text $Node)
        }

        if (Test-IsPrimitive -Value $Node) {
            return $Node
        }

        if ($Node -is [System.Collections.IDictionary]) {
            $map = [ordered]@{}
            foreach ($key in @($Node.Keys)) {
                $value = $Node[$key]
                if ([string]$key -match '(?i)target|computer|host|hostname|server') {
                    $map[$key] = Get-RedactedHostname -Name ([string]$value)
                }
                else {
                    $map[$key] = Convert-Node -Node $value
                }
            }
            return [pscustomobject]$map
        }

        # Arrays / lists (but not string — already handled)
        if ($Node -is [System.Array] -or $Node -is [System.Collections.IList]) {
            $list = [System.Collections.Generic.List[object]]::new()
            foreach ($item in $Node) {
                $list.Add((Convert-Node -Node $item))
            }
            return @($list.ToArray())
        }

        # PSCustomObject / other objects with note properties
        $noteProps = @(
            $Node.PSObject.Properties |
                Where-Object { $_.MemberType -eq 'NoteProperty' -or $_.MemberType -eq 'Property' }
        )

        if ($noteProps.Length -gt 0) {
            $map = [ordered]@{}
            foreach ($prop in $noteProps) {
                if ($prop.Name -match '(?i)target|computer|host|hostname|server') {
                    $map[$prop.Name] = Get-RedactedHostname -Name ([string]$prop.Value)
                }
                else {
                    $map[$prop.Name] = Convert-Node -Node $prop.Value
                }
            }
            if (@($map.Keys).Count -gt 0) {
                return [pscustomobject]$map
            }
        }

        return $Node
    }

    return (Convert-Node -Node $InputObject)
}
