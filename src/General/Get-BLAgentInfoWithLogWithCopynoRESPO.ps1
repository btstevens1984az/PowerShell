# Purpose: Get-BLAgentInfoWithLogWithCopynoRESPO — General-purpose PowerShell utilities.
# use start-transcript to get log of script actions
# change machine data list path and file name to current location and file name of server list

$LogOutputTrans = $((Get-Date).ToString('yyyyMMdd-hhmm') + "_CheckAgentTrans.txt")
start-transcript -Path "\\114.148.18.125\updatesinventory$\Transcripts\$LogOutputTrans" -IncludeInvocationHeader

$ErrorActionPreference= 'SilentlyContinue'
$FilePathFix = "\\114.148.18.125\g$\BLAgentFix\"
$WordToFind= "srvadmin"
$MachineData = get-content "c:\PSDEV\BLA-CHECKnoresponse.txt"
$LogOutputName = $((Get-Date).ToString('yyyyMMdd-hhmm') + "_CheckAgentSettings.txt")
$timeStarted = get-date
Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "All systems starting processing at $timeStarted"

	foreach ($ServerItem in $MachineData) {
		Write-Host -ForegroundColor Yellow $ServerItem " is processing now"
		Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "************************"
		Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "$ServerItem  is processing now"
# test if online		
		If ((Test-Connection -computername $ServerItem -Quiet) -eq $true) {
		
# check local accounts
		# Get-WmiObject -Class Win32_UserAccount -Namespace "root\cimv2" -filter "LocalAccount='True'" -ComputerName $ServerItem | FT
		$LocalUserAccount = ""
		$LocalUserAccount2 = ""
		$NameFound = ""
		$NameFound2 = ""
		
		$LocalUserAccount = Get-WmiObject -Class Win32_UserAccount -Namespace "root\cimv2" -filter "Name='srvadmin'" -ComputerName $ServerItem |select-object name
		$Namefound = $localUserAccount.name
		 
		 If ($LocalUserAccount.name -eq "srvadmin") {
				write-host -ForegroundColor Green $NameFound is the Local administrator user account
				Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "$NameFound is the Local administrator user account"
				}
				
#	

		$LocalUserAccount2 = Get-WmiObject -Class Win32_UserAccount -Namespace "root\cimv2" -filter "Name='Administrator'" -ComputerName $ServerItem |select-object name
		$Namefound2 = $localUserAccount2.name
		 
		 If ($LocalUserAccount2.name -eq "Administrator") {
		# doesnt check for admin sid ending in 500 which indicates admin	#domain controllers do use have local accounts
				write-host -ForegroundColor Red $NameFound2 is the Local administrator user account
				Write-Host -ForegroundColor Red "Administrator has not been renamed"
				Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "$NameFound2 is the Local administrator user account"
				Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "Administrator user account not renamed"
				}
		
# check path for RSC dir and dates of 177.210.68.248 filen
#if path fails - assume agent is not installed.  verify that install files are on server call install after srvadmin local account is verified.
# if path true - check exports and 151.17.42.141 files
	
		$TestPathDir = test-path "\\$ServerItem\c$\windows\rsc"
			
			If ($TestPathDir -eq $True) {
				write-host -ForegroundColor Green Windows rsc directory exists
				Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "Windows rsc directory exists"
				
	# compare date	LastWriteTime = 7/29/2017 else copy new exports file into directory	
	# if date is correct then check 151.17.42.141 file for srvadmin mapping
			
			$exportsFileInfo = get-item "\\$ServerItem\c$\windows\rsc\exports" |select-object Name, LastWriteTime
				$writeTime = $exportsFileInfo.LastWriteTime.date
			
				write-host -ForegroundColor Green "exports file date is " $exportsFileInfo.lastWriteTime
				Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "exports file date is  $WriteTime"
				
				If ($writeTime -ne "7/29/2017") {
				write-host -ForegroundColor Red "Exports file is not correct version" $writeTime
				Copy-Item "\\114.148.18.125\g$\blAgentFix\exports" -Destination "\\$ServerItem\c$\windows\rsc\"
				Copy-Item "\\114.148.18.125\g$\blAgentFix\151.17.42.141" -Destination "\\$ServerItem\c$\windows\rsc\"
				}
				
				If ($writeTime -eq "7/29/2017") {
				write-host -ForegroundColor Green "Exports file is the correct version" $exportsFileInfo.lastWriteTime
				# Copy-Item "\\114.148.18.125\g$\blAgentFix\exports" -Destination "\\$ServerItem\c$\windows\rsc\"
				# Copy-Item "\\114.148.18.125\g$\blAgentFix\151.17.42.141" -Destination "\\$ServerItem\c$\windows\rsc\"
				}
			
			$userslocalFileInfo = get-item "\\$ServerItem\c$\windows\rsc\151.17.42.141" |select-object Name, LastWriteTime
			
			$fileTest = Get-Content "\\$ServerItem\c$\windows\rsc\151.17.42.141" | Select-String "srvadmin" -quiet
				
				If ($fileTest -eq $True) {
				write-host -ForegroundColor Green "151.17.42.141 has srvadmin mapped"
				Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "151.17.42.141 has srvadmin mapped"
				}
				
				If ($fileTest -ne $True) {
				write-host -ForegroundColor Red "srvadmin local account not found in 151.17.42.141 file"
				Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "srvadmin local account not found in 151.17.42.141 file"
				}
				
				If (TestPathDir -ne $True) {
				write-host -ForegroundColor Red "Windows rsc directory not found"
				Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "Windows rsc directory not found"
				}				
            }
			
# check for RSCDsvc service and verify it is running
				
				$serviceCheck = get-service -Name "RSCDsvc" -ComputerName $ServerItem | select-object Name, Status, StartType
				# create variables with value to allow simple output in Add-Content line - displays only data when enclosed in quotes
				$serviceName = $serviceCheck.name
				$serviceStatus = $serviceCheck.Status
				$serviceStartType =  $serviceCheck.StartType
				
				If ($serviceCheck.name -eq "RSCDsvc") {
				Write-Host -ForegroundColor Green "Service Name - Status - Start Setting" $servicename $serviceStatus $serviceStartType
				Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "Service Name - Status - Start Setting  $serviceName $serviceStatus $serviceStartType"
				}
				
				If ($serviceCheck.name -ne "RSCDsvc") {
				Write-Host -ForegroundColor Red "Service RSCDsvc not found"
				Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "Service RSCDsvc not found"
				}
	}
		
	Else { 
				Write-Host -ForegroundColor RED $ServerItem "NOT ONLINE"
				Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName"  "$ServerItem not online No further processing done"			
				}
			Write-Host -ForegroundColor Yellow $ServerItem Completed 
			Write-Host "     Next System        "
			Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" " $ServerItem Completed "
			Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" " "
}
Write-Host -ForegroundColor GREEN "All systems have completed processing"
$timeCompleted = get-date
Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "All systems have completed processing $timeCompleted"
stop-transcript