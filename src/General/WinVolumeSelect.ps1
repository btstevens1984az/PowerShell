# Purpose: WinVolumeSelect — General-purpose PowerShell utilities.
$volumes = Get-WmiObject win32_volume
$hash = @{
 name="FreeSpaceGB"
 Expression={[int](($_.freespace)/1GB)}
 }

 $volumes | Select-Object name,$hash