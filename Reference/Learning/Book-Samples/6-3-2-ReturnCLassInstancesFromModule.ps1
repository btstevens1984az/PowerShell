# Purpose: 6-3 2 ReturnCLassInstancesFromModule — Certification notes and learning materials.
#Return instances from module
#Demo in new Powershell tab
Import-Module .\ComputerInfo2.psm1

$CompInfo = Get-ComputerInfo -ComputerName 38.255.240.239 
$CompInfo | Get-Member
$compinfo.GetStatus() 

$ComputerNames = $computers = 5..1 | %{"testsrv$_"}
$results = $ComputerNames | Get-ComputerInfo
$results | Sort-Object | Select-Object ComputerName,OsName,Status | FT -AutoSize

[computerinfo] | Get-Member -Static #Type is not definied in this scope.