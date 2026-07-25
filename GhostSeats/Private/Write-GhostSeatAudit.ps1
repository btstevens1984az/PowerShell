function Write-GhostSeatAudit {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Action,

        [hashtable]$Data
    )

    $config = Get-GhostSeatsConfigStore
    $path = $config.AuditLogPath
    $dir = Split-Path -Parent $path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    $entry = [ordered]@{
        timestampUtc = [datetime]::UtcNow.ToString('o')
        action       = $Action
        demoMode     = [bool]$config.DemoMode
        tenantId     = $config.TenantId
        data         = $Data
    }

    ($entry | ConvertTo-Json -Compress -Depth 6) | Add-Content -LiteralPath $path -Encoding UTF8
}
