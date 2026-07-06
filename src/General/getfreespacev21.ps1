# Purpose: getfreespacev21 — General-purpose PowerShell utilities.
#This script users a special hash table and string modifier to show percent free disk space.

$servers =gc c:\servers.txt
Get-WmiObject Win32_logicalDisk -Filter "DriveType=3" -ComputerName $servers | `
FT __Server,DeviceID,FreeSpace,Size,@{l="PercentFree";e={"{0:p}" -f ((([Int64]($_.freespace))/([Int64]($_.size))))}} -auto