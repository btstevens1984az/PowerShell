function New-JobPack {
    <#
    .SYNOPSIS
        Builds a signed job pack: playbook content hash + optional HMAC using an ephemeral local key.
    .NOTES
        Ephemeral key material lives only under $env:TEMP/LegionPS and is never committed.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [System.IO.FileInfo]$PlaybookFile,

        [Parameter(Mandatory)]
        [string[]]$Targets,

        [Parameter()]
        [hashtable]$Parameters = @{},

        [Parameter()]
        [ValidateSet('None', 'Required')]
        [string]$ApprovalMode = 'None',

        [Parameter()]
        [switch]$UseHmac
    )

    $content = Get-Content -LiteralPath $PlaybookFile.FullName -Raw -Encoding utf8
    $contentBytes = [System.Text.Encoding]::UTF8.GetBytes($content)

    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $hashBytes = $sha.ComputeHash($contentBytes)
        $contentHash = [System.BitConverter]::ToString($hashBytes).Replace('-', '').ToLowerInvariant()
    }
    finally {
        $sha.Dispose()
    }

    $hmacSignature = $null
    $keyId = $null

    if ($UseHmac) {
        $keyDir = Join-Path $script:LegionTempRoot 'keys'
        if (-not (Test-Path -LiteralPath $keyDir)) {
            New-Item -ItemType Directory -Path $keyDir -Force | Out-Null
        }

        $keyPath = Join-Path $keyDir 'ephemeral.key'
        if (-not (Test-Path -LiteralPath $keyPath)) {
            $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
            try {
                $raw = New-Object byte[] 32
                $rng.GetBytes($raw)
                [System.IO.File]::WriteAllBytes($keyPath, $raw)
            }
            finally {
                $rng.Dispose()
            }
        }

        $keyBytes = [System.IO.File]::ReadAllBytes($keyPath)
        $hmac = [System.Security.Cryptography.HMACSHA256]::new($keyBytes)
        try {
            $sigBytes = $hmac.ComputeHash($contentBytes)
            $hmacSignature = [System.BitConverter]::ToString($sigBytes).Replace('-', '').ToLowerInvariant()
            $keyId = 'ephemeral-local'
        }
        finally {
            $hmac.Dispose()
        }
    }

    $jobId = [guid]::NewGuid().ToString('N')

    return [pscustomobject]@{
        PSTypeName      = 'LegionPS.JobPack'
        JobId           = $jobId
        Playbook        = $PlaybookFile.BaseName
        PlaybookPath    = $PlaybookFile.FullName
        Targets         = @($Targets)
        Parameters      = $Parameters
        ApprovalMode    = $ApprovalMode
        Approved        = ($ApprovalMode -eq 'None')
        ApprovedAt      = if ($ApprovalMode -eq 'None') { [datetime]::UtcNow } else { $null }
        Approver        = $null
        ApprovalComment = $null
        ContentSha256   = $contentHash
        HmacSignature   = $hmacSignature
        HmacKeyId       = $keyId
        CreatedAt       = [datetime]::UtcNow
        FinishedAt      = $null
        Status          = if ($ApprovalMode -eq 'Required') { 'PendingApproval' } else { 'Ready' }
        Results         = @()
    }
}
