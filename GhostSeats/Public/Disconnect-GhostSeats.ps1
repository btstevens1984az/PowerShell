function Disconnect-GhostSeats {
    <#
    .SYNOPSIS
        Disconnects GhostSeats / Microsoft Graph session.
    #>
    [CmdletBinding()]
    param()

    $config = Get-GhostSeatsConfigStore
    $wasDemo = $config.DemoMode

    if (-not $wasDemo -and (Get-Command Disconnect-MgGraph -ErrorAction SilentlyContinue)) {
        Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
    }

    $config.Connected = $false
    $config.DemoMode = $false
    $config.TenantId = $null

    Write-GhostSeatAudit -Action 'Disconnect-GhostSeats' -Data @{ wasDemo = $wasDemo }
    Write-Host 'GhostSeats disconnected.' -ForegroundColor Yellow
}
