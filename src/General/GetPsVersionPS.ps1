# Purpose: GetPsVersionPS — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------------------
# GetPsVersionPs.ps1
# ed wilson, msft, 10/15/2008
#
# ------------------------------------------------------------------------------------
$path = "HKLM:\SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine"
$psv = get-itemproperty -path $path
$psv.RunTimeVersion