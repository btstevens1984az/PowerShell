# Purpose: Scopes — General-purpose PowerShell utilities.
$test = 123

function testscope
{
 $test
 $test = 1234
 $test
}

testscope
$test

$a ="str5"
$b = $a
$a = "str10"
$a
$b
 
 $x =get-service
function GetRightAnswer
{
param($x)
$x =Get-Process
$var = Get-Variable -Name x -Scope 1
Set-Variable -Name x -Scope 1 -Value (Get-Process notepad)

}
GetRightAnswer $x
$x