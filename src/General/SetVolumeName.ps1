# Purpose: SetVolumeName — General-purpose PowerShell utilities.
$wmi = Get-WmiObject -Class win32_LogicalDisk -Filter "name = 'c:' "
$wmi.VolumeName = "Local_Disk"
$wmi.Put()