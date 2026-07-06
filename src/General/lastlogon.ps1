# Purpose: lastlogon — General-purpose PowerShell utilities.

$list = New-Object Collections.ArrayList
$list.AddRange((Get-QADPSSnapinSettings -Integer8AttributesThatContainDateTimes))
$list.Add('lastLogon')
Set-QADPSSnapinSettings -Integer8AttributesThatContainDateTimes $list.ToArray([string])

get-QADUser -ip lastLogon | ft name, lastLogon 