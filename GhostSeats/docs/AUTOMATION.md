# GhostSeats automation runbook

## Weekly IT job (safe default)

```powershell
Import-Module /path/to/GhostSeats/GhostSeats.psd1
Connect-GhostSeats -TenantId $env:TENANT_ID   # or app-only params
Invoke-GhostSeatAutomation -OutputPath "D:\Reports\GhostSeats\$(Get-Date -Format yyyyMMdd)" -AutoApproveDisabled
# Email / Teams the HTML report + approval CSV for manager review
```

## Controlled reclaim

1. Managers edit `GhostSeats-Approval.csv` and set `Approved=true`.
2. IT runs:

```powershell
Invoke-GhostSeatReclaim -ApprovalListPath .\GhostSeats-Approval.csv -WhatIf
Invoke-GhostSeatReclaim -ApprovalListPath .\GhostSeats-Approval.csv
```

## Azure Automation notes

- Use a managed identity or cert-based app registration.
- Store reports in Azure Files / Blob / SharePoint.
- Keep `-ExecuteReclaim` off until the approval process is proven.
- Audit JSONL path should be on persistent storage.
