# Purpose: AddOne6 — General-purpose PowerShell utilities.
# AddOne6.ps1

Function AddOne($int)
{
 ${Global:AddOne6.number} =  $int + 1 
}

AddOne(5)
${AddOne6.number} | get-member
'Display the value of ${AddOne6.number}: ' + ${AddOne6.number}