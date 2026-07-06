# Purpose: Download-DeviceStatusReport — Security auditing and compliance checks.
Function Download-DeviceStatusReport {
#grab the .csv report from Radia
Invoke-WebRequest -Uri "http://114.148.18.125:3466/reportingserver/export.tcl?repRole=DEF&window=RPMCompliancebyDevices.window&RPMCompliancebyDevices-windowmode=export" | Select-Object -ExpandProperty content | Out-File "C:\Users\$env:USERNAME\Desktop\Radia\DeviceStatusReport.csv" -Encoding default
}