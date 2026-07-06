# Purpose: lastlogon2 — General-purpose PowerShell utilities.

$list = New-Object Collections.ArrayList
$list.AddRange((Get-QADPSSnapinSettings -Integer8AttributesThatContainDateTimes))
$list.Add('lastLogon')
Set-QADPSSnapinSettings -Integer8AttributesThatContainDateTimes $list.ToArray([string])

get-QADUser -ip lastLogon | export-csv c:\powershellreports\LastLogon60.csv