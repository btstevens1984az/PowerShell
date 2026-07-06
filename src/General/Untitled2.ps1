# Purpose: Untitled2 — General-purpose PowerShell utilities.
$SrchBase = "OU=Domain Controllers,DC=kaylos,DC=lab" ## point to the topmost OU to cover all sub OUs
. c:\temp\FunctionGPUpdate.ps1
GPUpdateRemote -SrchBase $SrchBase -Verbose