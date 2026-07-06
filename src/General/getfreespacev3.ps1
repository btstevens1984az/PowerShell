# Purpose: getfreespacev3 — General-purpose PowerShell utilities.
$servers = get-content .\computers.txt
Get-WmiObject Win32_logicalDisk -Filter "DriveType=3" -ComputerName $servers | `
FT __Server,DeviceID,@{l="FreeGB";e={[int](($_.freespace)/1GB)}},@{l="SizeGB";e={[int](($_.size)/1GB)}},@{l="PercentFree";e={[int](((([Int64]($_.freespace))/([Int64]($_.size)))*100))}} -auto
