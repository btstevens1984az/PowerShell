# Purpose: stdregprov — General-purpose PowerShell utilities.
#https://msdn.microsoft.com/en-us/library/aa390387(v=vs.85).aspx
$HKCU = 2147483649 
$reg = [wmiclass]"root\default:stdregprov"
$reg.Enumvalues($HKCU,"Software\\7-Zip").snames