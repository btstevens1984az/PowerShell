# Purpose: GetBiosTryCatchFinally — Hardware and software inventory collection.
# ------------------------------------------------------------------------
# DATE: 5/10/2009
#
# KEYWORDS: try catch finally
#
# COMMENTS: This script uses try catch finally to catch
# error that arises when no command line argument is
# supplied.
#
#
# ------------------------------------------------------------------------
Try 
   { Get-Wmiobject -class Win32_Bios -computer $args }
Catch [System.Management.Automation.ParameterBindingException]  
   { Write-Host -foregroundcolor cyan "Please enter computer name" }
Finally 
   { 'Cleaning up the $error object' ; $error.clear() }