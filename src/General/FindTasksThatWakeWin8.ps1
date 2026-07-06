# Purpose: FindTasksThatWakeWin8 — General-purpose PowerShell utilities.
Get-ScheduledTask | Where-Object {$_.settings.wakeToRun}