# M365-GhostLicensing automation runbook

## Weekly IT job (safe default)

```powershell
Import-Module /path/to/M365-GhostLicensing/M365-GhostLicensing.psd1
Connect-GhostLicensing -TenantId $env:TENANT_ID   # or app-only params
Invoke-GhostLicenseAutomation -OutputPath "D:\Reports\M365-GhostLicensing\$(Get-Date -Format yyyyMMdd)" -AutoApproveDisabled
# Email / Teams the HTML report + approval CSV for manager review
```

## Controlled reclaim

1. Managers edit `GhostLicense-Approval.csv` and set `Approved=true`.
2. IT runs:

```powershell
Invoke-GhostLicenseReclaim -ApprovalListPath .\GhostLicense-Approval.csv -WhatIf
Invoke-GhostLicenseReclaim -ApprovalListPath .\GhostLicense-Approval.csv
```

## Azure Automation notes

- Use a managed identity or cert-based app registration.
- Store reports in Azure Files / Blob / SharePoint.
- Keep `-ExecuteReclaim` off until the approval process is proven.
- Audit JSONL path should be on persistent storage.
