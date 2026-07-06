# Purpose: Copy-GroupMembersToGroupfunction — General-purpose PowerShell utilities.


Import-Module ActiveDirectory


#Start function

function Copy-GroupMembers {
	# this function copies users from one group to another and 
	# outputs the SamAccountNames of the members added.
	# Usage 
	# Copy-GroupMembers -sourcegroup "Group1" -destgroup "Group2" -copynestedusers $true
	# Copy-GroupMembers -sourcegroup "Group1" -destgroup "Group2"
	
	param (
	$sourcegroup = $(throw "Funtion Copy-GroupMembers needs -sourcegroup defined"),
	$destgroup = $(throw "Funtion Copy-GroupMembers needs -destgroup defined"),
	[bool]$copynestedusers = $(throw "Funtion Copy-GroupMembers needs -copynestedusers defined With either $true or $false"),
	$logfile
	
	)
	$ErrorActionPreference = "silentlycontinue"
	$membersadded = new-object system.Collections.ArrayList
	$membersnotadded = new-object system.Collections.ArrayList
		
	#check Source and Dests Group existance
	$sourcegroup = Get-ADGroup $sourcegroup
	if ($error) {
		Write-Host "An error occured when getting the members of the source group please check source group name" 
		Write-host "Exiting"
		$error.clear()
		exit
		
		}
	$destgroup = Get-ADGroup $destgroup
	if ($error) {
		Write-Host "An error occured when getting the members of the source group please check source group name" 
		Write-host "Exiting"
		$error.clear()
		exit
		
		}
		
	#Nested users section
	if ($copynestedusers) {
		$sorcemembers = Get-ADGroupMember -Identity $sourcegroup -Recursive | ? {$_.objectclass -eq "user"} 
		if ($error) {
			Write-Host "An error occured when getting the members of the source group please check source group name" 
			Write-host "Exiting"
			$error.clear()
			exit
		}
		else {
			$sorcemembers | % {Add-ADGroupMember -Identity $destgroup -Members $_
				if ($error) {
					$membersnotadded.Add($($_.samaccountname)) | Out-Null
					$Error.clear()
					}
				else {
					$membersadded.Add($($_.samaccountname)) | Out-Null
					}
				
			}	
		}

		
	}
	
	
	#Direct members only section
	else {
		$sorcemembers = Get-ADGroupMember -Identity $sourcegroup | ? {$_.objectclass -eq "user"} 
		
		if ($error) {
			Write-Host "An error occured when getting the members of the source group please check source group name" 
			Write-host "Exiting"
			$error.clear()
			exit
		}		
		else {
			$sorcemembers | % {Add-ADGroupMember -Identity $destgroup -Members $_
				if ($error) {
					$membersnotadded.Add($($_.samaccountname)) | Out-Null
					$Error.clear()
					}
				else {
					$membersadded.Add($($_.samaccountname)) | Out-Null
					}
				
				}	
		}
	}
Write-Host `r	
Write-Host "**** copynestedusers was set to $copynestedusers ****" -ForegroundColor 'white' -BackgroundColor 'Black'
Write-Host `r	
Write-Host "members added from group $($sourcegroup.SamAccountName) to group $($destgroup.SamAccountName) were" -ForegroundColor 'Green'
$membersadded | % {write-host $_ -ForegroundColor 'Green'}
Write-Host `r	
Write-Host "members NOT added from group $($sourcegroup.SamAccountName) to group $($destgroup.SamAccountName) were" -ForegroundColor 'Red' -BackgroundColor 'White'
$membersnotadded| % {write-host $_ -ForegroundColor 'Red'}
Write-Host `r	
	if($logfile) {
		Write-host "Logging results to $logfile" -ForegroundColor 'Green' -BackgroundColor 'Black'
		Add-Content $logfile -value `r
		Add-Content $logfile -value `r
		Add-Content $logfile -value "$(get-date)    ******* Start of LOG  ********"
		Add-Content $logfile -value "copynestedusers was set to $copynestedusers"
		Add-Content $logfile -Value "Members added from group $($sourcegroup.SamAccountName) to group $($destgroup.SamAccountName) were" 
		Add-Content $logfile -value `r
		$membersadded | % {Add-Content $logfile -Value "$_"  }
		
		Add-Content $logfile -value `r
		Add-Content $logfile -value `r
		Add-Content $logfile -Value "Members NOT added from group $($sourcegroup.SamAccountName) to group $($destgroup.SamAccountName) were" 
		Add-Content $logfile -value `r
		$membersnotadded | % {Add-Content $logfile -Value "$_"	}
		Add-Content $logfile -value `r
		Add-Content $logfile -value `r
		Add-Content $logfile -value "$(get-date)     ******** End of Log *********"
		Add-Content $logfile -value `r
		Add-Content $logfile -value `r
					
	} #end if($logfile)
	else {
		Write-host "No log file given...Not Logging results" -ForegroundColor 'Yellow'
		}
	
	
	
} #End function



### Start of script

$logfilepath = "H:\scripts\AddToGroupsFromGroupsLog.txt" 

Copy-GroupMembers -sourcegroup "ExampleSourceGroup" -destgroup "ExampleDestGroup" -copynestedusers $true -logfile $logfilepath


Write-Host `r	
Write-Host "Script Complete" -ForegroundColor 'Green'
Write-Host `r	



