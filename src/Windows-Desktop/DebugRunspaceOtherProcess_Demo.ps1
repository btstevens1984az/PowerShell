# Purpose: DebugRunspaceOtherProcess Demo — Windows desktop configuration and management.
$cred = Get-Credential
#Launch Process as other user
Start-Process powershell.exe -ArgumentList "-NoProfile -NoExit -file c:\pshell\demos\testscript.ps1 " -Credential $cred

#Assumes only one powershell.exe process
$PSH = Get-Process powershell
Enter-PSHostProcess -Id $PSH.Id
#cls; cd\
Get-Runspace

Debug-Runspace 1

#Ctrl-C or detach to exit debugging
Exit-PSHostProcess

