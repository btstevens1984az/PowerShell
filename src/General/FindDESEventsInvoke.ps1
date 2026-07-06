# Purpose: FindDESEventsInvoke — General-purpose PowerShell utilities.
#Find DES logins
Function GetForestDomainControllers
#Returns an array of all domain controllers in the forest
{
	Import-Module ActiveDirectory -ErrorAction Stop
	$cNC = (Get-ADRootDSE).configurationNamingContext
	$results = Get-ADObject -filter {objectclass -eq 'nTDSDSA'} -SearchBase $cNC
	$DCs = $Results | %{(((($_.distinguishedname).Split(","))[1]).split("="))[1]}
	$DCs
}
$DomainControllers = GetForestDomainControllers
$Desevents = Invoke-Command -ComputerName $DomainControllers -ThrottleLimit 50 -ScriptBlock {Get-EventLog -LogName security |
Where-Object{$_.eventid -eq 4769 -and $_.message -match "Ticket Encryption Type:\t0x(1|3)\r"}}
$DesEvents | Out-GridView