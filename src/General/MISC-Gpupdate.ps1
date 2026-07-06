# Purpose: MISC-Gpupdate — General-purpose PowerShell utilities.
#   James Wylde

$clientName = Get-Content c:\temp\computers.txt

C:\temp\temp\tools\paexec.exe \\$clientName cmd /C "netsh advfirewall firewall add rule dir=in name ="WMI" program=%systemroot%\system32\svchost.exe service=winmgmt action = allow protocol=TCP localport=any & call netsh firewall set service RemoteAdmin enable & netsh firewall add portopening protocol=tcp port=135 name=DCOM_TCP135" | Out-File -FilePath C:\Temp\gpresult.txt

#Get-Content -Path C:\temp\TeamsRDPfix\result.txt