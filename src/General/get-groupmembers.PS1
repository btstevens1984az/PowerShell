# Purpose: get-groupmembers — General-purpose PowerShell utilities.

param($ParentGroupNames)

$Global:myCol = @()

function Indent
	{
	param([Int]$Level)
	$Global:Indent = $null
	For ($x = 1 ; $x -le $Level ; $x++)
		{
		$Global:Indent += "`t"
		}
	}

function Get-MySubGroupMembersRecursive
	{
	param($DNs)
	ForEach ($DN in $DNs)
		{
		$Object = Get-QADObject $DN
		If ($Object.Type -eq "Group")
			{
			$i++
			Indent $i
			Write-Host ("{0}{1}" -f $Indent,$Object.DisplayName) -ForegroundColor "yellow"
			$Group = Get-QADGroup $DN
			If ($Group.Members.Length -ge 1)
				{
				Get-MySubGroupMembersRecursive $Group.Members
				}
			$i--
			Indent $i
			Clear-Variable Group -ErrorAction SilentlyContinue
			}
		Else
			{
			$userfound = Get-QADUser $DN | Select Name, Email
			Write-Host ("{0} {1}" -f $Indent,$userfound.Name)
			$Global:myCol += $userfound
			Clear-Variable userfound -ErrorAction SilentlyContinue
			}
		}
	}

ForEach ($ParentGroupName in $ParentGroupNames)
	{
	$Global:Indent = $null
	$ParentGroup = Get-QADGroup -Name $ParentGroupName
	Write-Host "====================="
	Write-Host " TREE VIEW PER GROUP"
	Write-Host "====================="
	Write-Host ("{0}" -f $ParentGroup.DisplayName) -ForegroundColor "yellow"
	If ($ParentGroup -eq $null)
		{
		Write-Warning "Group $ParentGroupName not found."
		break
		}
	Else
		{
		$FirstMembers = $ParentGroup.Members
		ForEach ($member in $firstmembers)
			{
			Get-MySubGroupMembersRecursive $member
			}
		}
	}
Write-Host ""
Write-Host "====================="	
Write-Host " All Unique Members: "
Write-Host "====================="	
$myCol | Sort Name | Select Name, Email -Unique