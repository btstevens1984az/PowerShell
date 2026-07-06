# Purpose: GetDefaultRegValue — General-purpose PowerShell utilities.
#Demonstrates how to retrieve the default registry value on a registry Key
#This method can be useful on retrieving any property which has a name with parenthesis

$test = get-itemproperty HKCU:\software\test
$test
$test.'(default)'