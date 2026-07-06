# Purpose: EnableLCMResourceDebug — Core infrastructure automation scripts.
$computer = "testsrv9"
Enable-DscDebug -CimSession $computer -BreakAll
#Disable-DscDebug -CimSession $computer