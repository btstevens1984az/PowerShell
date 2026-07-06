# Purpose: GetFunctionalLevels — General-purpose PowerShell utilities.
Import-Module ActiveDirectory -ErrorAction Stop

Function GetFunctionalLevelsADWS
{
	$DCs = GetForestDomainControllers
	$FunctionalLevelInfo = $dcs | 
	%{Write-host "Getting Functional Level info for:$_" ; Get-ADRootDSE -Properties domainControllerFunctionality,domainFunctionality,forestFunctionality -Server $_ | Select-Object dnshostname,domainControllerFunctionality,domainFunctionality,forestFunctionality}
	$FunctionalLevelInfo

}

Function GetFunctionalLevels
{
	$DCs = GetForestDomainControllers
	$FunctionalLevelInfo = $dcs | 
	%{Write-host "Getting Functional Level info for:$_" ;[ADSI]"LDAP://$_/RootDSE"| Select-Object dnshostname,domainControllerFunctionality,domainFunctionality,forestFunctionality}
	$FunctionalLevelInfo

}

Function GetForestDomainControllers
{
	Import-Module ActiveDirectory
	$cNC = (Get-ADRootDSE).configurationNamingContext
	$results = Get-ADObject -filter {objectclass -eq 'nTDSDSA'} -SearchBase $cNC
	$DCs = $Results | %{(((($_.distinguishedname).Split(","))[1]).split("="))[1]}
	$DCs
}

GetFunctionalLevelsADWS | Out-GridView