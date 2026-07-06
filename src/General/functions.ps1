# Purpose: functions — General-purpose PowerShell utilities.
function Select-Color
{
param(
[ValidateSet(‘Red’,’Green’,’Blue’)]
$Color
)
“You chose $Color”
}

function ConvertTo-Binary
{
param($Number)
“Original Number: $Number”
[System.Convert]::ToString($Number, 2)
return
}

function Test-Function
{
param($Parameter1=’Nothing1’, $Parameter2=’Nothing2’)
“You entered $Parameter1 and $Parameter2”
}

function Test-MandatoryParam {
param
(
[Parameter(Mandatory=$true)]
$name
)
“You entered $name.”
}