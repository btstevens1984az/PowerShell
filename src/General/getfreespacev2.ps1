# Purpose: getfreespacev2 — General-purpose PowerShell utilities.
$servers =gc c:\servers.txt
$servers = "localhost"
Get-WmiObject Win32_logicalDisk -Filter "DriveType=3" -ComputerName $servers | `
FT __Server,DeviceID,FreeSpace,Size,@{l="PercentFree";e={[int](((([Int64]($_.freespace))/([Int64]($_.size)))*100))}} -auto