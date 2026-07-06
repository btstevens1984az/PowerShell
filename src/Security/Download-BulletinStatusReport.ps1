# Purpose: Download-BulletinStatusReport — Security auditing and compliance checks.
Function Download-BulletinStatusReport {
#grab the .csv report from Radia
Invoke-WebRequest -Uri "http://114.148.18.125:3466/reportingserver/export.tcl?repRole=DEF&window=RPMCompliancebyBulletins.window&RPMCompliancebyBulletins-windowmode=export" | Select-Object -ExpandProperty content | Out-File "C:\Users\$env:USERNAME\Desktop\Radia\BulletinStatusReport.csv" -Encoding default
}