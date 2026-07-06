# Purpose: Rounding — General-purpose PowerShell utilities.
$disk = Get-WmiObject Win32_logicaldisk -filter "deviceid='c:'"
[math]::round(($disk.freespace/1GB),2)