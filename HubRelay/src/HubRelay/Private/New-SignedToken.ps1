function New-SignedToken {
    <#
    .SYNOPSIS
        Creates a random shared bearer token suitable for HUBRELAY_TOKEN.
    .NOTES
        Tokens are never written to disk by HubRelay. Copy the value into your environment only.
    #>
    [CmdletBinding()]
    param(
        [ValidateRange(16, 128)]
        [int] $ByteLength = 32
    )

    $bytes = [byte[]]::new($ByteLength)
    [System.Security.Cryptography.RandomNumberGenerator]::Fill($bytes)
    $token = [Convert]::ToBase64String($bytes).TrimEnd('=').Replace('+', '-').Replace('/', '_')
    return $token
}

function Get-HubTokenHash {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Token
    )

    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Token)
        $hash = $sha.ComputeHash($bytes)
        return ([BitConverter]::ToString($hash) -replace '-', '').ToLowerInvariant()
    }
    finally {
        $sha.Dispose()
    }
}

function Test-HubBearerAuth {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Net.HttpListenerRequest] $Request
    )

    $header = $Request.Headers['Authorization']
    if ([string]::IsNullOrWhiteSpace($header) -or -not $header.StartsWith('Bearer ', [StringComparison]::OrdinalIgnoreCase)) {
        return $false
    }

    $presented = $header.Substring(7).Trim()
    if ([string]::IsNullOrEmpty($presented) -or [string]::IsNullOrEmpty($script:HubRelayState.TokenHash)) {
        return $false
    }

    $presentedHash = Get-HubTokenHash -Token $presented
    $a = [System.Text.Encoding]::UTF8.GetBytes($presentedHash)
    $b = [System.Text.Encoding]::UTF8.GetBytes([string]$script:HubRelayState.TokenHash)
    if ($a.Length -ne $b.Length) { return $false }
    $diff = 0
    for ($i = 0; $i -lt $a.Length; $i++) { $diff = $diff -bor ($a[$i] -bxor $b[$i]) }
    return ($diff -eq 0)
}

function Test-HubRateLimit {
    [CmdletBinding()]
    param()

    $now = [datetime]::UtcNow
    $windowStart = $now.AddMinutes(-1)
    $list = $script:HubRelayState.RequestTimestamps

    while ($list.Count -gt 0 -and $list[0] -lt $windowStart) {
        $list.RemoveAt(0)
    }

    if ($list.Count -ge $script:HubRelayState.RateLimitPerMinute) {
        return $false
    }

    $list.Add($now)
    return $true
}
