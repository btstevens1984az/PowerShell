# Purpose: Ch12Improved — General-purpose PowerShell utilities.
#Give localservice rights to manage the printer
$printername = "accounting"
$trigger = New-ScheduledTaskTrigger -Daily -At 3am
$action = New-scheduledTaskAction -execute "Powershell" -Argument "-command & {Get-printjob -printername '$printername' | remove-printjob}"
$principal = New-ScheduledTaskPrincipal -UserId "LOCALSERVICE" -LogonType ServiceAccount
$task = New-ScheduledTask -Action $action -Description "Printer Queue Maintenance" -Trigger $trigger -Principal $principal
$task | Register-ScheduledTask -TaskName "Printer Maintenance"

help help | Out-Printer -Name $printername