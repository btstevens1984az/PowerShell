# Purpose: testHidden — General-purpose PowerShell utilities.
class testHidden
{
 hidden [string]$hiddenproperty = "test"
 hidden [string]HiddenMethod(){return "test hidden method"}
 [int]$normalProperty = 2
}
$testHidden = [testHidden]::new()
$testHidden | Select-Object *  #Will not see hidden
$testhidden | Select-Object *,HiddenProperty #will see hiddenproperty
$testHidden| Get-member -Force #Displays hidden members
$testHidden.HiddenProperty 
$testHidden.HiddenMethod()