# Purpose: CMID — General-purpose PowerShell utilities.
#Get CMID, this will show you if clients have different CMIDs because if they don't they were not likely sysprepped correctly and this will cause problems with KMS activation.

Function GetForestDomainControllers
{
	Import-Module ActiveDirectory
	$cNC = (Get-ADRootDSE).configurationNamingContext
	$results = Get-ADObject -filter {objectclass -eq 'nTDSDSA'} -SearchBase $cNC
	$DCs = $Results | %{(((($_.distinguishedname).Split(","))[1]).split("="))[1]}
	$DCs
}

$DCs = GetForestDomainControllers

Get-WmiObject softwarelicensingservice -ComputerName $DCs | Select-Object __server,ClientMachineID,DiscoveredKeyManagementServiceMachineName |
Out-GridView