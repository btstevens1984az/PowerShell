# Purpose: Copy-Groupfunction — Active Directory user, group, and domain administration.


Import-Module ActiveDirectory


#Start function

function Copy-GroupMembers {
	# This function copies users from one group to another and 
	# outputs the SamAccountNames of the members added.
	# Usage 
	# Copy-GroupMembers -sourcegroup "Group1" -destgroup "Group2" -copynestedusers $true
	# Copy-GroupMembers -sourcegroup "Group1" -destgroup "Group2"
	
	param (
	$sourcegroup,
	$destgroup,
	[bool]$copynestedusers
	
	)
	$ErrorActionPreference = "silentlycontinue"
	$membersadded = new-object system.Collections.ArrayList
	$membersaddedcount = 0
	
	$error.clear()
	if ($copynestedusers) {
		$sorcemembers = Get-ADGroupMember -Identity $sourcegroup -Recursive | 
			? {$_.objectclass -eq "user"} 
		if ($error) {
			Write-Host "An error occured when getting the members of the source group please check source group name" 
			Write-host "Exiting"
			$error.clear()
			exit
		}
		
		$destmebers =  Get-ADGroupMember -Identity $destgroup
		if ($error) {
			Write-Host "An error occured when getting the members of the destination group please check destination group name" 
			Write-host "Exiting"
			$error.clear()
			exit
		}
		
		if ($destmebers) {
			$netmebers = Compare-Object $sorcemembers $destmebers | ? {$_.SideIndicator -eq "<="}
			if ($netmebers) {
				foreach ($member in $netmebers) {
					Add-ADGroupMember -Identity $destgroup -Members $member.InputObject
					$membersadded.Add($($member.InputObject.samaccountname)) | Out-Null
				}
			}
			else {
				write-host "All of $sourcegroup members are already in $destgroup"	
			}

		}	
		else {
			$sorcemembers | % {Add-ADGroupMember -Identity $destgroup -Members $_
				$membersadded.Add($($_.samaccountname)) | Out-Null
			}	
		}
	}

	else {
		$sorcemembers = Get-ADGroupMember -Identity $sourcegroup | 
			? {$_.objectclass -eq "user"} 
		
		if ($error) {
			Write-Host "An error occured when getting the members of the source group please check source group name" 
			Write-host "Exiting"
			$error.clear()
			exit
		}
		
		$destmebers =  Get-ADGroupMember -Identity $destgroup
		if ($error) {
			Write-Host "An error occured when getting the members of the destination group please check destination group name" 
			Write-host "Exiting"
			$error.clear()
			exit
		}
		
		if ($destmebers) {
			$netmebers = Compare-Object $sorcemembers $destmebers | ? {$_.SideIndicator -eq "<="}
			if ($netmebers) {
				foreach ($member in $netmebers) {
					Add-ADGroupMember -Identity $destgroup -Members $member.InputObject
					$membersadded.Add($($member.InputObject.samaccountname)) | Out-Null
				}
			}
			else {
				write-host "All of $sourcegroup members are already in $destgroup"	
			}

		}	
		else {
			$sorcemembers | % {Add-ADGroupMember -Identity $destgroup -Members $_
				$membersadded.Add($($_.samaccountname)) | Out-Null
				
				}	
		}
	}
	return $membersadded 
} 


#End function


### Start of script
$usersadded = Copy-GroupMembers -sourcegroup "ExampleSourceGroup" -destgroup "ExampleDestGroup" -copynestedusers $true

Write-Host "members added were"
$usersadded



