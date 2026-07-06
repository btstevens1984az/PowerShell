# Purpose: LargeGroups2 — General-purpose PowerShell utilities.
#POC Script on moving members from a large group to nested groups
#Version 1.1
#More error handling needed
#This is a sample script and is intended to simply provide an example but was not designed or tested for production use.
#The sample scripts are not supported under any Microsoft standard support program or service. 
#The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, 
#any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample 
#scripts and documentation remains with you. In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery 
#of the scripts be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, 
#loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages.

param($groupName = "largeGroup")

$starttime = get-date
$Error.Clear()
if (-not (Get-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction SilentlyContinue)) 
{
	Write-Host "Attempting to load Quest Active Roles cmdlets..."
	Add-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction stop
	Write-Host "Quest Active Roles cmdlets loaded successfully."
}
$numUsers = 0
Write-Verbose "$(Get-date) :Binding to Group:$groupName"
$LargeGroup = Get-QadGroup $groupName
$ParentDN = $largeGroup.parentContainerDN
#added filter to ensure only users are returned, this takes a long time....
#If no filtering is needed $largegroup.members is much faster but other parts of script will need to be changed (i.e.  $NewGroup $_.DN to $NewGroup $_)
Write-Verbose "$(Get-date) :Loading group membership"
$members = Get-QADGroupmember $LargeGroup -type "user" -SizeLimit 0
Write-Verbose "$(Get-date) :Loading group membership complete. Number of group members:$($members.count)"
if ($members.count -ge 4500)
	{
	#Export DNs of group memebers to be moved to provide a roll back plan.
	Write-Verbose "$(Get-date) Export Group membership to XML file"
	$members | Select-Object DN | Export-Clixml "$groupname.xml"
	Write-Verbose "$(Get-date) Export Group membership to XML file complete."
	$groupType = $LargeGroup.get_GroupType()
	$GroupScope = $LargeGroup.get_GroupScope()
	$totalMembers = $members.count
	[double]$numNewGroups = ($totalmembers/4500)
	$Remainder = $numNewGroups %([int]$numNewGroups)
	if  ($Remainder -eq 0 -or $Remainder -ge .5)
	{
		$numNewGroups = ([int]$numNewGroups) 
		Write-Host "$numNewGroups new groups will be created"
		#no action required
	}
	elseif ($Remainder -le .5)
	{
		#round up new groups
		$numNewGroups = ([int]$numNewGroups)+1
		Write-Host "$numNewGroups new groups will be created"
	}
	for($i=1;$i -le $numNewGroups;$i++)
	{
		Write-Verbose "$(Get-date) :Createing new Group: $(($largegroup.name)+$i)"
		New-QadGroup -name $(($largegroup.name)+$i) -GroupType $GroupType -GroupScope $GroupScope `
			-ParentContainer $ParentDN -SamAccountName $(($largegroup.name)+$i)
		$NewGroup = Get-QADGroup $(($largegroup.name)+$i)	
		Add-QADGroupMember $LargeGroup ($NewGroup.DN)
		$Userlimit=((4500*$i)-1)
		If($Userlimit -ge $members.Count)
		{ $Userlimit = $members.Count - 1}
		Write-Verbose "$(Get-date) : Moving Group members"
		$members[$numUsers..$userlimit] | %{Add-QADGroupMember $NewGroup $_.DN}
		$members[$numUsers..$userlimit] | %{remove-QADGroupMember $LargeGroup $_.DN}
		$numUsers=4500*$i	
		Write-Verbose "$(Get-date) : Done adding members to $(($largegroup.name)+$i)"
	}	
	}
Else
{Write-Host "No large group detected or other error encountered"}

$Error | Out-File "$LargeGroupErrors.txt"
$Error.Clear()
$endtime = Get-Date
$Minutes = ($endtime - $starttime).TotalMinutes
Write-Host "Script finished in $minutes minutes"