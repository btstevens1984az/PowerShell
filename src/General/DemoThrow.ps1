# Purpose: DemoThrow — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 3/8/2009
#
# KEYWORDS: Demo, throw statement, function,
# $errorActionPreference, $error
# COMMENTS: This demonstrates using the throw
# statement to raise an error and using the $error 
# object to retrieve information about that error.
#
# PowerShell Best Practices
# ------------------------------------------------------------------------
Function Set-Error
{
 $errorActionPreference = "SilentlyContinue"
 "Before the throw statement: $($error.count) errors"
 $value = "bad"
 If ($value -eq "bad") 
   { throw "The value is bad" }
} #end Set-Error

Function Get-ErrorDetails
{
 "After the throw statement: $($error.count) errors"
 "Error details:"
 $error[0] | Format-List -Property * 
 "Invocation information:"
 $error[0].InvocationInfo
} #end Get-ErrorDetails

# *** Entry Point to Script
Set-Error
Get-ErrorDetails
