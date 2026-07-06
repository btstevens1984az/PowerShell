# Purpose: GetPsVersionNet — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE:
#
# KEYWORDS: Registry, .NET Framework
#
# COMMENTS: This script retrieves the value of the ps
# version by using the .NET Framework Registry class
# Microsoft.Win32.Registry has the getvalue static method
# The three parameters are the root\key the value and the
# default value. Here we just use $null for the default. 
# ------------------------------------------------------------------------

$hklm = "HKEY_LOCAL_MACHINE"
$key = "SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine"
$value = "RunTimeVersion"
[Microsoft.Win32.Registry]::GetValue("$hklm\$key",$value,$null)