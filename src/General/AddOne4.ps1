# Purpose: AddOne4 — General-purpose PowerShell utilities.
# AddOne4.ps1

Function AddOne($int)
{
 $global:number =  $int + 1 
}

AddOne(5)
$global:number | get-member
'Display the value of $global:number: ' + $global:number