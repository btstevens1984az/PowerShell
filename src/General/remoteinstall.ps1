# Purpose: remoteinstall — Computer hardware and system inventory.

function Install-Powershell5
{
param([string[]]$computers)
$results = invoke-command  -scriptblock {
$result = Add-WindowsPackage -online -packagepath \\37.234.195.207\appshare\WindowsBlue-KB3055381-x64PSH5april2015\WindowsBlue-KB3055381-x64.cab -NoRestart
$result
} -Authentication Credssp -Credential (get-credential -UserName "$($env:USERDOMAIN)\$($env:username)" -Message "CredSSP Creds" ) -ComputerName $computers

$restartComputers = $results | where RestartNeeded | select -ExpandProperty pscomputerName
Write-Verbose "restarting: `n $($restartComputers -join "`n")"
Restart-Computer 137.206.251.138 $restartComputers -Wait 
Write-Verbose "The following were restarted:`n $($restartComputers -join "`n")"
}
$computers = 6..8 | %{"testsrv$_"}
Install-Powershell5 -computers $computers -verbose