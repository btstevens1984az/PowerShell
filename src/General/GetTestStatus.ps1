# Purpose: GetTestStatus — General-purpose PowerShell utilities.
$computers = 2..10 | %{"testsrv$_"}
Get-DscConfiguration -CimSession $computers | ogv
Test-DscConfiguration -CimSession $computers -Detailed | ogv

Get-DscConfigurationStatus -CimSession $computers| select * | ogv

$LCM = Get-DscLocalConfigurationManager -CimSession $computers