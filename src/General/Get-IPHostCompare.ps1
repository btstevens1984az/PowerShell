# Purpose: Get-IPHostCompare — General-purpose PowerShell utilities.
# use start-transcript to get log of script actions
# change machine data list path and file name to current location and file name of server list

# $LogOutputTrans = $((Get-Date).ToString('yyyyMMdd-hhmm') + "_CheckHostNameWMIfromIPList.txt")
# start-transcript -Path "\\114.148.18.125\updatesinventory$\Transcripts\$LogOutputTrans" -IncludeInvocationHeader

$ErrorActionPreference= 'SilentlyContinue'
$RecheckList = @()
# $WordToFind= "srvadmin"
$ListIP = get-content "c:\tempkk\IPList.txt"
$LogOutputName = $((Get-Date).ToString('yyyyMMdd-hhmm') + "_CheckHostNameIP.txt")
# $timeStarted = get-date
# Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "All systems starting processing at $timeStarted"

	foreach ($computerIP in $ListIP) {
		Write-Host -ForegroundColor Yellow $ComputerIP " is processing now"
		#Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "************************"
		#Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "$ComputerIP is processing now"
		
# test if online
		
		If ((Test-Connection -computername $ComputerIP -Quiet) -eq $true) 
	{
		
#get hostname from WMI

		$LocalComputerName = Get-WmiObject -Class Win32_ComputerSystem -Namespace "root\cimv2" -ComputerName $ComputerIP | Select-Object Name
		
		$Result1Name = $localComputerName.name
#
				Write-Host -ForegroundColor Yellow "WMI Results $ComputerIP is $Result1Name"
				#Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "$ComputerIP $NameFound"
	
# Test-NetConnection -ComputerName $Result1Name -InformationLevel Detailed	

	$result2 = nslookup $ComputerIP 
	$result2name = $result2
			Write-Host -ForegroundColor Yellow "NSLOOKUP Results $ComputerIP is $Result2Name"
			If ($result1name -eq $result2name){
			Write-Host "Names match - $result1name $result2name"
			}
			If ($result1name -ne $result2name){
			Write-Host -ForegroundColor RED "Names DO NOT match - $result1name $result2name adding IP to recheck list"
			$RecheckList += "$computerIP"
			write-host "recheck list is now $rechecklist"
			}
	}
		
	Else { 
				Write-Host -ForegroundColor RED $ComputerIP "NOT ONLINE"
				#Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName"  "$ComputerIP not online No further processing done"			
				}
				
			Write-Host -ForegroundColor Yellow $ServerItem Completed 
			Write-Host "     Next System        "
			#Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" " $ServerItem Completed "
			#Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" " "
}
$timeCompleted = get-date
Write-Host -ForegroundColor GREEN "All systems have completed processing $timeCompleted"

# Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "All systems have completed processing $timeCompleted"
