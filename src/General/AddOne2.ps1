# Purpose: AddOne2 — General-purpose PowerShell utilities.
# AddOne2.ps1

Function AddOne($int)
{
 Write-Host $int + 1 
}

$number = AddOne(5)
$number | get-member
'Display the value of $number: ' + $number