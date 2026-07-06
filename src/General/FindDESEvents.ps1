# Purpose: FindDESEvents — General-purpose PowerShell utilities.
#Find security events showing accounts using DES for Kerberos. DES is disabled by default on Windows 2008 R2 domain controllers
#so this script can help you determine when you can disabled DES for Kerberos.
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

$events = Get-WmiObject -Class Win32_NTLogEvent -Filter "logfile = 'security' and eventcode= 4769" `
-computername $DomainControllers

#Filter on DES events
$DesEvents = $events | where-object{$_.message -match "Ticket Encryption Type:\t0x1\r" -or $_.message -match "Ticket Encryption Type:\t0x3\r"}
$DesEvents | Out-GridView




#***********************************************Disclaimer **************************************************
#The sample scripts are not supported under any Microsoft standard support program or service. 
#The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied 
#warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.
#The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. 
#In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be
#liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption,
#loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation,
#even if Microsoft has been advised of the possibility of such damages. 
