#Requires -Version 7.0
<#
.SYNOPSIS
    Pester-friendly tests for LegionPS (also runnable without Pester for basic asserts).
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$moduleManifest = Join-Path $PSScriptRoot '..' 'src' 'LegionPS' 'LegionPS.psd1' | Resolve-Path
Import-Module $moduleManifest -Force

$script:Failures = 0

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) {
        Write-Host "FAIL: $Message" -ForegroundColor Red
        $script:Failures++
    }
    else {
        Write-Host "PASS: $Message" -ForegroundColor Green
    }
}

# --- Playbook allowlist ---
$books = @(Get-LegionPlaybook)
Assert-True ($books.Count -ge 3) 'Get-LegionPlaybook returns allowlisted playbooks'

$one = Get-LegionPlaybook -Name Restart-Spooler
Assert-True ($one.Name -eq 'Restart-Spooler') 'Get-LegionPlaybook finds Restart-Spooler'

$refused = $false
$tmpEvil = Join-Path ([System.IO.Path]::GetTempPath()) 'legionps-evil-test.ps1'
try {
    Set-Content -LiteralPath $tmpEvil -Value '# not an allowlisted playbook' -Encoding utf8
    try {
        Invoke-LegionJob -Playbook $tmpEvil -Targets 'web-01' -Simulation | Out-Null
    }
    catch {
        $refused = ($_.Exception.Message -match 'outside|Refused|allowlist|Playbooks')
    }
}
finally {
    Remove-Item -LiteralPath $tmpEvil -Force -ErrorAction SilentlyContinue
}
Assert-True $refused 'Invoke-LegionJob refuses paths outside Playbooks/'

# --- Plan object is JSON-serializable ---
$plan = New-LegionPlan -Playbook Get-ServiceHealth -Targets 'web-01', 'db-02' -Rationale 'test'
$json = $plan | ConvertTo-Json -Depth 5
Assert-True ($json -match 'Get-ServiceHealth') 'New-LegionPlan serializes to JSON'
Assert-True ($plan.Targets -contains 'web-01') 'Plan includes fictional targets'

# --- Simulation fan-out ---
$job = Invoke-LegionJob -Playbook Get-ServiceHealth -Targets 'web-01', 'app-03' -Simulation -ThrottleLimit 2
Assert-True ($job.Status -eq 'Completed') 'Invoke-LegionJob Simulation completes'
Assert-True ($job.Results.Count -eq 2) 'Simulation returns one result per target'
Assert-True ($null -ne $job.ContentSha256 -and $job.ContentSha256.Length -eq 64) 'Job pack includes SHA256 of playbook'

# --- Approval gate ---
$gated = Invoke-LegionJob -Playbook Restart-Spooler -Targets 'db-02' -ApprovalMode Required -Simulation
Assert-True ($gated.Status -eq 'PendingApproval') 'ApprovalMode Required leaves job pending'
$approved = Approve-LegionJob -JobId $gated.JobId -Approver 'tester'
Assert-True ($approved.Approved -eq $true) 'Approve-LegionJob marks Approved'
$ran = Invoke-LegionJob -JobId $gated.JobId -Simulation
Assert-True ($ran.Status -eq 'Completed') 'Approved job can be executed'

# --- DryRun ---
$dry = Invoke-LegionJob -Playbook Clear-TempSafe -Targets 'app-03' -DryRun -Simulation
Assert-True ($dry.Results[0].Status -eq 'DryRun') 'DryRun reports DryRun status'

# --- Redaction ---
$export = Export-LegionSummary -JobId $job.JobId -PassThru
Assert-True ($export -match '\*') 'Export redacts hostname characters'
Assert-True ($export -match 'we') 'Export retains partial hostname prefix for web-01'

# Inject a secret-like string into a stored job via module scope for redaction coverage
$job2 = Invoke-LegionJob -Playbook Get-ServiceHealth -Targets 'web-01' -Simulation
$mod = Get-Module LegionPS
& $mod {
    param($Id)
    $stored = $null
    if ($script:LegionJobStore.TryGetValue($Id, [ref]$stored)) {
        $stored.Results[0] | Add-Member -NotePropertyName Note -NotePropertyValue 'password=SuperSecret123' -Force
        $script:LegionJobStore[$Id] = $stored
    }
} -Id $job2.JobId

$scrubbed = Export-LegionSummary -JobId $job2.JobId -PassThru
Assert-True ($scrubbed -match '\[REDACTED\]') 'Redact-Result strips password patterns'
Assert-True ($scrubbed -notmatch 'SuperSecret123') 'Secret value not present in export'

# --- Get-LegionJob ---
$listed = @(Get-LegionJob)
Assert-True ($listed.Count -ge 1) 'Get-LegionJob lists in-session jobs'
$fetched = Get-LegionJob -JobId $job.JobId
Assert-True ($fetched.JobId -eq $job.JobId) 'Get-LegionJob fetches by Id'

Write-Host ""
if ($script:Failures -gt 0) {
    Write-Host "$script:Failures test(s) failed." -ForegroundColor Red
    exit 1
}
Write-Host 'All LegionPS tests passed.' -ForegroundColor Green
exit 0
