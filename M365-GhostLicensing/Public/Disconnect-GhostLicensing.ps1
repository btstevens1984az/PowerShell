function Disconnect-GhostLicensing {
    <#
    .SYNOPSIS
        Disconnects M365-GhostLicensing / Microsoft Graph session.
    #>
    [CmdletBinding()]
    param()

    $config = Get-GhostLicensingConfigStore
    $wasDemo = $config.DemoMode

    if (-not $wasDemo -and (Get-Command Disconnect-MgGraph -ErrorAction SilentlyContinue)) {
        Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
    }

    $config.Connected = $false
    $config.DemoMode = $false
    $config.TenantId = $null
    $config.AuthMethod = $null

    Write-GhostLicensingAudit -Action 'Disconnect-GhostLicensing' -Data @{ wasDemo = $wasDemo }
    Write-Host 'M365-GhostLicensing disconnected.' -ForegroundColor Yellow
}
