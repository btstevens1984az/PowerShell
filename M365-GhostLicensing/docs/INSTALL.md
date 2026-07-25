# Install and run M365-GhostLicensing

This guide is written for Windows, macOS, and Linux IT admins using **PowerShell 7** (recommended) or Windows PowerShell 5.1.

---

## 1. Prerequisites

1. **PowerShell 7.4+** (recommended)  
   - Windows / macOS / Linux: https://learn.microsoft.com/powershell/scripting/install/installing-powershell  
   - Confirm:

```powershell
$PSVersionTable.PSVersion
```

2. **Internet access** to:
   - `https://www.powershellgallery.com` (install)
   - `https://graph.microsoft.com` and Entra sign-in (live tenant mode)

3. For **live tenant** scanning you also need Graph modules (installed automatically below if missing) and an Entra account or app registration with:

| Permission | Purpose |
|---|---|
| `User.Read.All` | Read users and assigned licenses |
| `Directory.Read.All` | Directory inventory |
| `Organization.Read.All` | Subscribed SKUs |
| `AuditLog.Read.All` | Sign-in activity |
| `User.ReadWrite.All` | Only if you will reclaim licenses |

---

## 2. Install from PowerShell Gallery (recommended)

```powershell
# Current user (no admin elevation required)
Install-Module -Name M365-GhostLicensing -Scope CurrentUser -Repository PSGallery -Force

# Verify
Get-Module -ListAvailable M365-GhostLicensing
Import-Module M365-GhostLicensing
Get-Command -Module M365-GhostLicensing
```

If Gallery is untrusted in your environment:

```powershell
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name M365-GhostLicensing -Scope CurrentUser -Force
```

Update later:

```powershell
Update-Module -Name M365-GhostLicensing -Force
```

---

## 3. Install from GitHub (source)

```powershell
# Clone
git clone https://github.com/btstevens1984az/M365-GhostLicensing.git
cd M365-GhostLicensing

# Import directly from the repo folder
Import-Module ./M365-GhostLicensing.psd1 -Force

# Optional: install into your personal Modules path
$dest = Join-Path ($env:PSModulePath -split [IO.Path]::PathSeparator)[0] 'M365-GhostLicensing'
New-Item -ItemType Directory -Path $dest -Force | Out-Null
Copy-Item -Path ./* -Destination $dest -Recurse -Force
Import-Module M365-GhostLicensing -Force
```

---

## 4. First run — Contoso demo (no Entra required)

Use this to evaluate the module with zero tenant risk:

```powershell
Import-Module M365-GhostLicensing
Start-GhostLicensingDemo -OpenReport
```

What this does:

1. Connects to the built-in Contoso demo tenant  
2. Scans for unused licenses (“ghost licenses”)  
3. Exports HTML / CSV / JSON reports  
4. Builds an approval CSV  
5. Simulates reclaim for pre-approved disabled accounts  

Open the HTML report from the path printed at the end of the run.

Step-by-step equivalent:

```powershell
Import-Module M365-GhostLicensing
Connect-GhostLicensing -Demo
Get-GhostLicense | Format-Table
Get-GhostLicenseSummary
Export-GhostLicenseReport -Path ./reports -Open
```

---

## 5. Connect to your Azure Entra tenant

### Option A — Interactive browser (admins)

```powershell
Import-Module M365-GhostLicensing

# Install Graph auth stack once
Install-Module Microsoft.Graph.Authentication, Microsoft.Graph.Users, Microsoft.Graph.Identity.DirectoryManagement -Scope CurrentUser -Force

Connect-GhostLicensing -TenantId 'contoso.onmicrosoft.com'
# Add write scopes only when you are ready to reclaim:
# Connect-GhostLicensing -TenantId 'contoso.onmicrosoft.com' -IncludeReclaimScopes
```

A browser window opens. Sign in and consent (or use an account where admin consent was already granted).

### Option B — Device code (servers / jump boxes)

```powershell
Connect-GhostLicensing -TenantId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' -DeviceCode
```

Visit https://microsoft.com/devicelogin and enter the code shown in the console.

### Option C — App-only certificate (automation / Azure Automation)

1. Entra admin center → **App registrations** → New registration (`M365-GhostLicensing`)  
2. Certificates & secrets → upload certificate → copy thumbprint  
3. API permissions → Microsoft Graph **Application** permissions listed above → **Grant admin consent**  
4. Connect:

```powershell
Connect-GhostLicensing -TenantId $tid -ClientId $appId -CertificateThumbprint $thumb
```

### Option D — App-only client secret

```powershell
$secret = Read-Host 'Client secret' -AsSecureString
Connect-GhostLicensing -TenantId $tid -ClientId $appId -ClientSecret $secret
```

Prefer certificates over secrets in production.

Verify the session:

```powershell
Get-GhostLicensingConfig | Select-Object Connected, DemoMode, TenantId, AuthMethod
```

Disconnect when finished:

```powershell
Disconnect-GhostLicensing
```

---

## 6. Scan, report, and reclaim (live tenant)

```powershell
# Discover
Get-GhostLicense | Format-Table
Get-GhostLicenseSummary

# Leadership report
Export-GhostLicenseReport -Path "$HOME/GhostLicensing-Reports" -Open

# Change-control approval list
New-GhostLicenseApprovalList -Path ./approvals/week.csv -PreApproveDisabledAccounts
# Open the CSV, set Approved=true for rows you want to reclaim

# Always WhatIf first
Invoke-GhostLicenseReclaim -ApprovalListPath ./approvals/week.csv -WhatIf

# Execute reclaim for Approved=true rows
Invoke-GhostLicenseReclaim -ApprovalListPath ./approvals/week.csv
```

One-shot automation pipeline:

```powershell
Invoke-GhostLicenseAutomation -OutputPath ./out -AutoApproveDisabled -OpenReport
# Reclaim stage stays off unless you pass -ExecuteReclaim
```

---

## 7. Common configuration

```powershell
Set-GhostLicensingConfig -InactiveDays 60
Set-GhostLicensingConfig -ExcludeUpnPatterns 'breakglass*','svc-*@*','*-sa@*'
Set-GhostLicensingConfig -ExcludeDepartments 'Executive','Legal'
Get-GhostLicensingConfig
Get-GhostLicenseSkuCatalog | Format-Table
```

---

## 8. Uninstall

```powershell
Remove-Module M365-GhostLicensing -ErrorAction SilentlyContinue
Uninstall-Module M365-GhostLicensing -AllVersions -Force
```

---

## 9. Troubleshooting

| Symptom | Fix |
|---|---|
| `Microsoft.Graph.Authentication is required` | `Install-Module Microsoft.Graph.Authentication -Scope CurrentUser` |
| Sign-in activity empty | Needs Entra ID P1/P2 and `AuditLog.Read.All` |
| `Not connected` | Run `Connect-GhostLicensing` or `-Demo` first |
| Gallery install blocked | `Set-PSRepository PSGallery -InstallationPolicy Trusted` |
| Reclaim denied | Grant `User.ReadWrite.All` / license admin role; use approval CSV |

More detail: [AUTHENTICATION.md](AUTHENTICATION.md), [PERMISSIONS.md](PERMISSIONS.md), [AUTOMATION.md](AUTOMATION.md).
