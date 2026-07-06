# Purpose: delkeys — General-purpose PowerShell utilities.

#need recursion cannot delete keys with subkeys
$computer = "78.61.6.96"
$HKU =2147483651
$HKLM =2147483650
$wmireg = [WMICLASS]"\\$computer\root\default:stdregprov"
$wmikeys =$wmireg.EnumKey($HKU,"")
$hives = $wmikeys.snames
$temp ="software\microsoft\windows\currentversion\controls folder\powercfg"
$temp ="software\microsoft\windows\currentversion\test"
foreach ($hive in $hives)
{
$path="\control Panel\Powercfg"
$keypath=$hive+$path
Write-Host "$HKU,$keypath"
DeleteKey $computer $HKU $keypath
#$wmireg.DeleteKey($HKU,$keypath)

}


Function DeleteKey
{
	param($comp,$regHive,$regKeyPath)
	$wmireg = [WMICLASS]"\\$computer\root\default:stdregprov"
	$regkeys =$wmireg.EnumKey($regHive,$regKeyPath)
	if ($regkeys)
	{
		foreach ($key in $regkeys.snames)
		{
			DeleteKey $comp $regHive "$regKeyPath\$key"
		}
	}
	else
	{
		Write-host '$wmireg.DeleteKey($regHive,$regkeypath)'
	}

}


