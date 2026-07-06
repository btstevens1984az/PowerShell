# Purpose: zzzwmi — General-purpose PowerShell utilities.
clear-Host
$i=0
$Type = "Win32"
$WMI = get-WmiObject -list | Where-Object {$_.name -match $Type}
Foreach ($Class in $WMI) {$Class.name; $i++}
Write-Host 'There are' $i' types of '$Type