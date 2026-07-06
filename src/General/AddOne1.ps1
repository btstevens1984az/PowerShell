# Purpose: AddOne1 — General-purpose PowerShell utilities.
# AddOne1.ps1

Function AddOne($int)
{
 $int + 1 
}

$number = AddOne(5)
$number | get-member
'Display the value of $number: ' + $number
