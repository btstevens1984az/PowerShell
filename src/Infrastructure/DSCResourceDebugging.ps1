# Purpose: DSCResourceDebugging — Core infrastructure automation scripts.
Enable-DscDebug -CimSession testsrv3 -BreakAll
Disable-DscDebug -CimSession testsrv3
Start-DscConfiguration -CimSession testsrv3 -Wait -Verbose -UseExisting

#use the following on server that you want to debug
Get-PSHostProcessInfo
Get-RunspaceDebug

stop-service netlogon
start-servie spooler