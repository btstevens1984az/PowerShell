# Purpose: FixTerm — General-purpose PowerShell utilities.
#JD
#Function to fix issue where you cannot RDP after a reboot
#demostrates remote registry using WMI
#also demonstates binding to a WMI class using [WMICLASS] type accelerator
Function FixTerm
{
Begin
{
$HKCU = 2147483649
$HKLM = 2147483650
$ValuetoAdd1 = "TermDD"
[array]$addvalues = $ValuetoAdd1
$regKey = "system\currentcontrolset\services\termservice"
$regValueName = "DependOnService"
}
Process
{
$computer = $_
$wmireg = [WMICLASS]"\\$computer\root\default:stdregprov"
$reg = $wmireg.GetMultiStringValue($HKLM,$regKey,$regValueName)

If ($reg.returnvalue -eq 0)
{
	$currentValue = $reg.svalue
	$currentValue | Select-String $ValuetoAdd1 -OutVariable testmatch | Out-Null
	If (!$testmatch)
	{
		$newvalue = $currentValue + $addvalues
		$wmirtn = $wmiReg.setMultiStringValue($HKLM,$regKey,$regValueName,$newvalue)
		If ($wmirtn.returnvalue -eq 0)	
		{"Registry change successful to $computer"}
	}
	else
	{
		Write-Host "No registry change necessary on $computer"
	}
}
}
}