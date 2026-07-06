# Purpose: zzznew5 — General-purpose PowerShell utilities.
Function Get-OutlookVersion
{
 $OUTLOOKVer = ( Get-command "C:\program files\microsoft office\office12\OUTLOOK.exe" ).FileVersionInfo.ProductVersion
Out-File -filepath �C:\LOGS\OutlookVersion.txt� -append
 $Computer = ( Get-WmiObject Win32_ComputerSystem ).name
Out-File -filepath �C:\LOGS\OutlookVersion.txt� -append
 Backup-EventLogs($Folder)
} #end Get-OutlookVersion