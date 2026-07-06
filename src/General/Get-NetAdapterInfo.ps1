# Purpose: Get-NetAdapterInfo — General-purpose PowerShell utilities.
function Get-NetAdapterInfo {

Param($timeout = 10)

begin {$count = 0}

process {

Write-Output "Processing computer: $_" 

$session = New-CimSession –ComputerName $_ -OperationTimeoutSec $timeout

Get-NetAdapter –cimsession $session 

$count = $count + 1

}

end {Write-Output "$count computers were processed"}

} 
