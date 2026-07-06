# Purpose: checkServices — Windows desktop configuration and management.

$servers =Get-Content c:\servers.txt
Get-WmiObject Win32_service -computer $servers -filter "startmode='auto' and state!='Running'" | `
Select-Object __Server,Name,Startmode,State,ExitCode | sort-object __Server |FT -auto