# Purpose: REG-DelayedStart — Windows registry read and write operations.
#   James Wylde

Clear-Host

$ErrorActionPreference = 'silentlycontinue'

Write-Host "`r`n"
Write-Host "Enable RDP. Start Winrm. Create firewall exception. Apply Teams compatability regkeys."
Write-Host "`r`n"


$clientName = Read-Host 'Machine'

C:\temp\TeamsRDPfix\tools\paexec.exe \\$clientName cmd /C "reg.exe Add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc" /v DelayedAutoStart /T REG_SZ /d 1 /F & 


reg.exe Add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc" /v Start /T REG_SZ /d 2 /F"