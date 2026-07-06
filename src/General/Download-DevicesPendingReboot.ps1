# Purpose: Download-DevicesPendingReboot — General-purpose PowerShell utilities.
Function Download-DevicesPendingReboot {
#grab the .csv report from Radia
Invoke-WebRequest -Uri "http://114.148.18.125:3466/reportingserver/export.tcl?repRole=DEF&window=RPMDevicesPendingReboot.window&RPMDevicesPendingReboot-windowmode=export" | Select-Object -ExpandProperty content | Out-File "C:\Users\$env:USERNAME\Desktop\Radia\Devices_Pending_Reboot_Report.csv" -Encoding default
}