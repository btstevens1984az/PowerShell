function Connect-GhostLicensing {
    <#
    .SYNOPSIS
        Authenticates M365-GhostLicensing to your Azure Entra ID tenant via Microsoft Graph.
    .DESCRIPTION
        Supports multiple Entra authentication methods used by IT departments:

        - Interactive browser login (delegated)
        - Device code flow (for servers / remote sessions without a browser)
        - App-only with certificate
        - App-only with client secret
        - Pre-acquired access token
        - Contoso Demo mode (no Entra / Graph calls)

        Required Graph permissions for discovery:
        User.Read.All, Directory.Read.All, Organization.Read.All, AuditLog.Read.All

        For reclaim, also grant User.ReadWrite.All (or equivalent license admin role).
    .PARAMETER Demo
        Use the built-in Contoso demo tenant. No network calls.
    .PARAMETER TenantId
        Entra directory (tenant) ID or verified domain (e.g. contoso.onmicrosoft.com).
    .PARAMETER ClientId
        App registration (application) ID for app-only or custom public client auth.
    .PARAMETER CertificateThumbprint
        Certificate thumbprint registered on the Entra app (app-only).
    .PARAMETER ClientSecret
        Client secret SecureString for app-only auth.
    .PARAMETER DeviceCode
        Use device code flow (sign in at microsoft.com/devicelogin).
    .PARAMETER AccessToken
        Use an already-acquired Graph access token (SecureString recommended).
    .PARAMETER Scopes
        Override delegated Graph scopes for interactive / device-code auth.
    .PARAMETER IncludeReclaimScopes
        Adds User.ReadWrite.All for license removal workflows.
    .EXAMPLE
        Connect-GhostLicensing -Demo
    .EXAMPLE
        Connect-GhostLicensing -TenantId 'contoso.onmicrosoft.com'
    .EXAMPLE
        Connect-GhostLicensing -TenantId $tid -DeviceCode
    .EXAMPLE
        Connect-GhostLicensing -TenantId $tid -ClientId $appId -CertificateThumbprint $thumb
    .EXAMPLE
        $secret = Read-Host 'Client secret' -AsSecureString
        Connect-GhostLicensing -TenantId $tid -ClientId $appId -ClientSecret $secret
    #>
    [CmdletBinding(DefaultParameterSetName = 'Interactive')]
    param(
        [Parameter(ParameterSetName = 'Demo')]
        [switch]$Demo,

        [Parameter(ParameterSetName = 'Interactive')]
        [Parameter(ParameterSetName = 'DeviceCode')]
        [Parameter(ParameterSetName = 'Certificate', Mandatory)]
        [Parameter(ParameterSetName = 'ClientSecret', Mandatory)]
        [Parameter(ParameterSetName = 'AccessToken')]
        [string]$TenantId,

        [Parameter(ParameterSetName = 'Interactive')]
        [Parameter(ParameterSetName = 'DeviceCode')]
        [Parameter(ParameterSetName = 'Certificate', Mandatory)]
        [Parameter(ParameterSetName = 'ClientSecret', Mandatory)]
        [string]$ClientId,

        [Parameter(ParameterSetName = 'Certificate', Mandatory)]
        [string]$CertificateThumbprint,

        [Parameter(ParameterSetName = 'ClientSecret', Mandatory)]
        [securestring]$ClientSecret,

        [Parameter(ParameterSetName = 'DeviceCode')]
        [switch]$DeviceCode,

        [Parameter(ParameterSetName = 'AccessToken', Mandatory)]
        [securestring]$AccessToken,

        [Parameter(ParameterSetName = 'Interactive')]
        [Parameter(ParameterSetName = 'DeviceCode')]
        [string[]]$Scopes,

        [Parameter(ParameterSetName = 'Interactive')]
        [Parameter(ParameterSetName = 'DeviceCode')]
        [switch]$IncludeReclaimScopes
    )

    $config = Get-GhostLicensingConfigStore

    if ($Demo) {
        $demoTenant = Get-DemoTenantData
        $config.DemoMode = $true
        $config.Connected = $true
        $config.TenantId = $demoTenant.TenantId
        $config.AuthMethod = 'Demo'
        Write-GhostLicensingAudit -Action 'Connect-GhostLicensing' -Data @{ mode = 'Demo'; tenantId = $demoTenant.TenantId }
        Write-Host ""
        Write-Host "  Authenticated  : DEMO (Contoso synthetic tenant)" -ForegroundColor Green
        Write-Host "  Tenant         : $($demoTenant.TenantName)" -ForegroundColor Green
        Write-Host "  TenantId       : $($demoTenant.TenantId)" -ForegroundColor DarkGreen
        Write-Host "  Graph calls    : none" -ForegroundColor DarkGreen
        Write-Host ""
        return [pscustomobject]@{
            Mode       = 'Demo'
            AuthMethod = 'Demo'
            TenantId   = $demoTenant.TenantId
            TenantName = $demoTenant.TenantName
            Connected  = $true
        }
    }

    $connectCmd = Get-Command Connect-MgGraph -ErrorAction SilentlyContinue
    if (-not $connectCmd) {
        throw @"
Microsoft.Graph.Authentication is required to sign in to Azure Entra ID.

  Install-Module Microsoft.Graph.Authentication, Microsoft.Graph.Users, Microsoft.Graph.Identity.DirectoryManagement -Scope CurrentUser

Or explore safely with:

  Connect-GhostLicensing -Demo
"@
    }

    $defaultScopes = [System.Collections.Generic.List[string]]@(
        'User.Read.All'
        'Directory.Read.All'
        'Organization.Read.All'
        'AuditLog.Read.All'
    )
    if ($IncludeReclaimScopes) {
        $defaultScopes.Add('User.ReadWrite.All') | Out-Null
    }
    if (-not $Scopes) {
        $Scopes = @($defaultScopes)
    }

    Write-Host ""
    Write-Host "  M365-GhostLicensing · Azure Entra authentication" -ForegroundColor Cyan
    Write-Host "  ------------------------------------------------" -ForegroundColor DarkCyan

    $authMethod = $PSCmdlet.ParameterSetName
    $connectParams = @{ NoWelcome = $true }

    switch ($PSCmdlet.ParameterSetName) {
        'Interactive' {
            Write-Host "  Method         : Interactive browser (delegated)" -ForegroundColor Yellow
            $connectParams.Scopes = $Scopes
            if ($TenantId) { $connectParams.TenantId = $TenantId }
            if ($ClientId) { $connectParams.ClientId = $ClientId }
            Write-Host "  Action         : Complete sign-in in the browser window..." -ForegroundColor DarkYellow
            Connect-MgGraph @connectParams | Out-Null
        }
        'DeviceCode' {
            Write-Host "  Method         : Device code flow" -ForegroundColor Yellow
            $connectParams.Scopes = $Scopes
            $connectParams.UseDeviceCode = $true
            if ($TenantId) { $connectParams.TenantId = $TenantId }
            if ($ClientId) { $connectParams.ClientId = $ClientId }
            Write-Host "  Action         : Follow the device-code prompt (microsoft.com/devicelogin)" -ForegroundColor DarkYellow
            Connect-MgGraph @connectParams | Out-Null
        }
        'Certificate' {
            Write-Host "  Method         : App-only (certificate)" -ForegroundColor Yellow
            Write-Host "  TenantId       : $TenantId" -ForegroundColor DarkYellow
            Write-Host "  ClientId       : $ClientId" -ForegroundColor DarkYellow
            Connect-MgGraph -TenantId $TenantId -ClientId $ClientId -CertificateThumbprint $CertificateThumbprint -NoWelcome | Out-Null
        }
        'ClientSecret' {
            Write-Host "  Method         : App-only (client secret)" -ForegroundColor Yellow
            if (-not (Get-Command Get-Credential -ErrorAction SilentlyContinue)) {
                throw "Client secret auth requires a credential helper. Prefer -CertificateThumbprint in automation."
            }
            # Microsoft.Graph supports -ClientSecretCredential (PSCredential) on recent versions
            $cred = [pscredential]::new($ClientId, $ClientSecret)
            $secretParams = @{
                TenantId              = $TenantId
                ClientSecretCredential = $cred
                NoWelcome             = $true
            }
            try {
                Connect-MgGraph @secretParams | Out-Null
            }
            catch {
                throw @"
Client secret authentication failed: $($_.Exception.Message)

Ensure Microsoft.Graph.Authentication is up to date, and the Entra app has a valid client secret.
Prefer certificate auth for production automation:

  Connect-GhostLicensing -TenantId <tid> -ClientId <appId> -CertificateThumbprint <thumb>
"@
            }
        }
        'AccessToken' {
            Write-Host "  Method         : Access token" -ForegroundColor Yellow
            Connect-MgGraph -AccessToken $AccessToken -NoWelcome | Out-Null
        }
    }

    $context = Get-MgContext
    if (-not $context) {
        throw "Authentication did not establish a Microsoft Graph context."
    }

    $config.DemoMode = $false
    $config.Connected = $true
    $config.TenantId = $context.TenantId
    $config.AuthMethod = $authMethod

    Write-GhostLicensingAudit -Action 'Connect-GhostLicensing' -Data @{
        mode       = 'Graph'
        authMethod = $authMethod
        tenantId   = $context.TenantId
        account    = [string]$context.Account
        appName    = [string]$context.AppName
        scopes     = @($context.Scopes)
    }

    Write-Host "  Authenticated  : YES" -ForegroundColor Green
    Write-Host "  TenantId       : $($context.TenantId)" -ForegroundColor Green
    if ($context.Account) {
        Write-Host "  Account        : $($context.Account)" -ForegroundColor Green
    }
    if ($context.AppName) {
        Write-Host "  Application    : $($context.AppName)" -ForegroundColor Green
    }
    if ($context.AuthType) {
        Write-Host "  AuthType       : $($context.AuthType)" -ForegroundColor Green
    }
    if ($context.Scopes) {
        Write-Host "  Scopes         : $($context.Scopes -join ', ')" -ForegroundColor DarkGreen
    }
    Write-Host ""

    return [pscustomobject]@{
        Mode       = 'Graph'
        AuthMethod = $authMethod
        TenantId   = $context.TenantId
        Account    = $context.Account
        AppName    = $context.AppName
        AuthType   = $context.AuthType
        Scopes     = $context.Scopes
        Connected  = $true
    }
}
