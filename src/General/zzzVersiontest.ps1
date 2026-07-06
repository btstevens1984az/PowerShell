# Purpose: zzzVersiontest — General-purpose PowerShell utilities.
clear-Host
$i=0


$OUTLOOKVer = ( Get-command "C:\program files\microsoft office\office12\OUTLOOK.exe" ).FileVersionInfo.ProductVersion | Out-File -filepath �C:\LOGS\OutlookVersion.txt� -append

$computer = ( Get-WmiObject Win32_ComputerSystem ).name | Out-File -filepath �C:\LOGS\OutlookVersion.txt� -append
