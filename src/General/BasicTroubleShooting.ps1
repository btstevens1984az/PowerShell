# Purpose: BasicTroubleShooting — General-purpose PowerShell utilities.
#see whats in the desired state
Test-DscConfiguration -ComputerName 254.40.179.158 -Detailed

#verify LCM config
Get-DscLocalConfigurationManager -CimSession testsrv2

#run config, see if it throws errors
Start-DscConfiguration -ComputerName 254.40.179.158 -UseExisting -Verbose -Wait
#del the mofs
Remove-DscConfigurationDocument -Stage 

#see history of errors
Get-DscConfigurationStatus -CimSession testsrv2 -All
#invoke update from pull server to see errors
Update-DscConfiguration -CimSession testsrv2 -Wait -Verbose