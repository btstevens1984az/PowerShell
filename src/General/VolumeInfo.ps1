# Purpose: VolumeInfo — General-purpose PowerShell utilities.
$computername= "localhost"
gwmi "Win32_volume" -filter drivetype=3 -ComputerName $computerName | FT -Property DriveLetter,FileSystem,FreeSpace,DriveType -autosize
