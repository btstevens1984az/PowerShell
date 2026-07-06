# Purpose: DefragAnalysis — General-purpose PowerShell utilities.
$wmi = Get-WmiObject �class Win32_Volume �filter "name = 'c:'"
$return = $wmi.DefragAnalysis()
$return.DefragAnalysis
