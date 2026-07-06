# Purpose: Download-DeviceBulletinCompliance — General-purpose PowerShell utilities.
Function Download-DeviceBulletinCompliance {
#grab the .csv report from Radia
Invoke-WebRequest -Uri "http://114.148.18.125:3466/reportingserver/export.tcl?repRole=DEF&window=RPMCompliancebyDevicebyBulletins.window&RPMCompliancebyDevicebyBulletins-windowmode=export" | Select-Object -ExpandProperty content | Out-File "C:\Users\$env:USERNAME\Desktop\Radia\SelectedComputersBulletinsReport.csv" -Encoding default
}
