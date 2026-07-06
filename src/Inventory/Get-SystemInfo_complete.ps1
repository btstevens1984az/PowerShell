# Purpose: Get-SystemInfo_complete — Computer hardware and system inventory.
Function Get-SystemInfo {

param($machineName, $timeOut)

$session = New-CimSession –ComputerName $machineName –OperationTimeoutSec $timeOut

Get-Volume –cimsession $session 
Get-NetAdapter –cimsession $session | 
Select-Object –Property Name, InterfaceIndex, Status, PSComputerName
}

