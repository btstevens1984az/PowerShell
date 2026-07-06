# Purpose: tempreg — General-purpose PowerShell utilities.
Function GetDefaultUserName
{
param($computer)
$HKLM = 2147483650
$regKey="SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$regValueName ="DefaultUsername"
$wmireg = [WMICLASS]"\\$computer\root\default:stdregprov"
$reg = $wmireg.GetStringValue($HKLM,$regKey,$regValueName)
if ($reg.ReturnValue -eq 0)
{$reg.sValue}
else
{"error retrieving last logged on user"}

}