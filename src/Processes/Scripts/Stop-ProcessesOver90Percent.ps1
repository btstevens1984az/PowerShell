# Purpose: Stop-ProcessesOver90Percent — PowerShell automation.
Function Stop-ProcessesOver90Percent{
$hiproc = (Get-Counter "\Process(powershell*)\% Processor Time").CounterSamples
$hiprocID = (Get-Counter "\Process(powershell*)\ID Process").CounterSamples
    if($hiproc.CookedValue -gt 90){stop-process -ID $hiprocID.CookedValue}
    else {Write-Host "No single process is using more than 90% CPU resources. Exiting script"}
}