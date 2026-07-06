# Purpose: AddOne5 — General-purpose PowerShell utilities.
# AddOne5.ps1

Function AddOne($int)
{
 $script:number =  $int + 1 
}

AddOne(5)
$script:number | get-member
'Display the value of $script:number: ' + $script:number