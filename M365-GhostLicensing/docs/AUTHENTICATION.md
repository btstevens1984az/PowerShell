# M365-GhostLicensing — Azure Entra authentication

Sign in to your Entra ID tenant with `Connect-GhostLicensing`. Discovery uses Microsoft Graph.

## 1) Interactive browser (most common for admins)

```powershell
Install-Module Microsoft.Graph.Authentication, Microsoft.Graph.Users, Microsoft.Graph.Identity.DirectoryManagement -Scope CurrentUser

Import-Module ./M365-GhostLicensing/M365-GhostLicensing.psd1
Connect-GhostLicensing -TenantId 'contoso.onmicrosoft.com'
# Optional: request write scopes for reclaim
Connect-GhostLicensing -TenantId 'contoso.onmicrosoft.com' -IncludeReclaimScopes
```

A browser window opens. Sign in with an account that can consent (or that already has admin consent) for:

| Permission | Purpose |
|---|---|
| `User.Read.All` | Users + assigned licenses |
| `Directory.Read.All` | Directory inventory |
| `Organization.Read.All` | Subscribed SKUs |
| `AuditLog.Read.All` | Sign-in activity |
| `User.ReadWrite.All` | Reclaim only (`-IncludeReclaimScopes`) |

## 2) Device code (jump boxes / no local browser)

```powershell
Connect-GhostLicensing -TenantId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' -DeviceCode
```

Follow the code at `https://microsoft.com/devicelogin`.

## 3) App-only certificate (recommended for automation)

1. Entra admin center → **App registrations** → New registration (`M365-GhostLicensing`)
2. Certificates & secrets → upload cert → copy thumbprint
3. API permissions → Microsoft Graph **Application** permissions above → **Grant admin consent**
4. Connect:

```powershell
Connect-GhostLicensing -TenantId $tid -ClientId $appId -CertificateThumbprint $thumb
```

## 4) App-only client secret

```powershell
$secret = Read-Host 'Client secret' -AsSecureString
Connect-GhostLicensing -TenantId $tid -ClientId $appId -ClientSecret $secret
```

Prefer certificates over secrets for production.

## 5) Access token

```powershell
$token = ConvertTo-SecureString $env:GRAPH_TOKEN -AsPlainText -Force
Connect-GhostLicensing -AccessToken $token
```

## 6) Demo (no Entra)

```powershell
Connect-GhostLicensing -Demo
```

## Verify

```powershell
Get-GhostLicensingConfig | Select-Object Connected, DemoMode, TenantId, AuthMethod
Get-MgContext
```

## Disconnect

```powershell
Disconnect-GhostLicensing
```
