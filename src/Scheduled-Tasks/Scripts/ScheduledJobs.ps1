# Purpose: ScheduledJobs — PowerShell automation.
$trigger = New-JobTrigger -At ((get-date).AddSeconds(15)) -Once
$joboptions = New-ScheduledJobOption -RequireNetwork -StartIfIdle
#optionally specify triggers and options
Register-ScheduledJob -Name Get-ProcessJobDemo -ScriptBlock {Get-process} -RunNow
Get-ScheduledJob -Name Get-ProcessJobDemo |
Set-ScheduledJob -RunNow
