# Purpose: TestDSCConfig — Core infrastructure automation scripts.
$cimsessions = New-CimSession -ComputerName 24.11.111.17,dscpull2
Test-DscConfiguration -CimSession $cimsessions