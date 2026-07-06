# Purpose: GetPsVersionWmi — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 10/15/2008
#
# KEYWORDS: Registry, WMI
#
# COMMENTS: This script reads the registry by using WMI
# The hklm value comes from SDK and is a number
# The key value DOES NOT get a backslash in front of it!
# The value value is obvious
#
# ------------------------------------------------------------------------
$hklm = 2147483650
$key = "SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine"
$value = "RunTimeVersion"
$wmi = [wmiclass]"root\default:stdRegProv"
($wmi.GetStringValue($hklm,$key,$value)).svalue