function Connect-GhostSeats {
    <#
    .SYNOPSIS
        Connects GhostSeats to Microsoft Graph, or enables Contoso demo mode.
    .DESCRIPTION
        Live mode uses Microsoft Graph (Microsoft.Graph.Authentication / Users / Identity.DirectoryManagement).
        Demo mode loads a synthetic Contoso tenant so you can evaluate the module with zero tenant risk.
    .PARAMETER Demo
        Use the built-in Contoso demo tenant. No network calls.
    .PARAMETER TenantId
        Optional tenant ID for interactive Graph login.
    .PARAMETER ClientId
        Application (client) ID for app-only auth.
    .PARAMETER CertificateThumbprint
        Certificate thumbprint for app-only auth.
    .EXAMPLE
        Connect-GhostSeats -Demo
    .EXAMPLE
        Connect-GhostSeats -TenantId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
    #>
    [CmdletBinding(DefaultParameterSetName = 'Interactive')]
    param(
        [Parameter(ParameterSetName = 'Demo')]
        [switch]$Demo,

        [Parameter(ParameterSetName = 'Interactive')]
        [Parameter(ParameterSetName = 'App')]
        [string]$TenantId,

        [Parameter(ParameterSetName = 'App', Mandatory)]
        [string]$ClientId,

        [Parameter(ParameterSetName = 'App', Mandatory)]
        [string]$CertificateThumbprint
    )

    $config = Get-GhostSeatsConfigStore

    if ($Demo) {
        $demoTenant = Get-DemoTenantData
        $config.DemoMode = $true
        $config.Connected = $true
        $config.TenantId = $demoTenant.TenantId
        Write-GhostSeatAudit -Action 'Connect-GhostSeats' -Data @{ mode = 'Demo'; tenantId = $demoTenant.TenantId }
        Write-Host "Connected to GhostSeats DEMO tenant: $($demoTenant.TenantName)" -ForegroundColor Green
        return [pscustomobject]@{
            Mode       = 'Demo'
            TenantId   = $demoTenant.TenantId
            TenantName = $demoTenant.TenantName
            Connected  = $true
        }
    }

    $connectCmd = Get-Command Connect-MgGraph -ErrorAction SilentlyContinue
    if (-not $connectCmd) {
        throw @"
Microsoft.Graph.Authentication is required for live mode.

  Install-Module Microsoft.Graph.Authentication, Microsoft.Graph.Users, Microsoft.Graph.Identity.DirectoryManagement -Scope CurrentUser

Or explore safely with:

  Connect-GhostSeats -Demo
"@
    }

    $scopes = @(
        'User.Read.All'
        'Directory.Read.All'
        'Organization.Read.All'
        'AuditLog.Read.All'
    )

    if ($PSCmdlet.ParameterSetName -eq 'App') {
        Connect-MgGraph -TenantId $TenantId -ClientId $ClientId -CertificateThumbprint $CertificateThumbprint -NoWelcome | Out-Null
    }
    else {
        $connectParams = @{
            Scopes    = $scopes
            NoWelcome = $true
        }
        if ($TenantId) { $connectParams.TenantId = $TenantId }
        Connect-MgGraph @connectParams | Out-Null
    }

    $context = Get-MgContext
    $config.DemoMode = $false
    $config.Connected = $true
    $config.TenantId = $context.TenantId

    Write-GhostSeatAudit -Action 'Connect-GhostSeats' -Data @{ mode = 'Graph'; tenantId = $context.TenantId; scopes = $context.Scopes }
    Write-Host "Connected to Microsoft Graph tenant $($context.TenantId)" -ForegroundColor Green

    return [pscustomobject]@{
        Mode      = 'Graph'
        TenantId  = $context.TenantId
        Account   = $context.Account
        Scopes    = $context.Scopes
        Connected = $true
    }
}
