# Purpose: AddOne3 — General-purpose PowerShell utilities.
# AddOne3.ps1

Function AddOne($int)
{
 $number =  $int + 1 
}

$number = AddOne(5)
$number | get-member
'Display the value of $number: ' + $number