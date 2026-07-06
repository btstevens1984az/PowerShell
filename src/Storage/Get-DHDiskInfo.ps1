# Purpose: Get-DHDiskInfo — Storage management and disk operations.
Function Get-DHDiskInfo {
Param ([string]$computername='localhost',[int]$MinimumFreePercent=10)
$disks=Get-WmiObject -Class Win32_Logicaldisk -Filter "Drivetype=3"
foreach ($disk in $disks) {$perFree=($disk.FreeSpace/$disk.Size)*100;
if ($perFree -ge $MinimumFreePercent) {$OK=$True}
else {$OK=$False};$disk|Select DeviceID,VolumeName,Size,FreeSpace,`
@{Name="OK";Expression={$OK}}
}}
Get-DiskInfo