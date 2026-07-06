# Purpose: GetAvailableVMWin32Process — Windows desktop configuration and management.
#the WMI method used only exists on Windows 2012r2/8.1 or newer
$processes = Get-WmiObject -Class Win32_Process | Add-Member -MemberType ScriptProperty -Name AvailableVirtualSizeGB -Value {[math]::Round((($this.GetAvailableVirtualSize()).AvailableVirtualSize/1Gb),2)} -PassThru
$processes | select name,AvailableVirtualSizeGB,ExecutablePath,PeakVirtualSize,VirtualSize | Sort-Object AvailableVirtualSizeGB -Descending | Out-GridView
