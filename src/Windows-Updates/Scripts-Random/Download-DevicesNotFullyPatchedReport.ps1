# Purpose: Download-DevicesNotFullyPatchedReport — Windows Update and patch management.
Function Download-DevicesNotFullyPatchedReport {
#grab the .csv report from Radia
Invoke-WebRequest -Uri "http://114.148.18.125:3466/reportingserver/export.tcl?repRole=DEF&window=RPMDevicesNotPatched.window&RPMDevicesNotPatched-windowmode=export" | Select-Object -ExpandProperty content | Out-File "C:\Users\$env:USERNAME\Desktop\Radia\Devices_Not_Fully_Patched_Report.csv" -Encoding default
}