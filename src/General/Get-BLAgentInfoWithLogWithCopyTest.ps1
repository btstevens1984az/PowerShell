# Purpose: Get-BLAgentInfoWithLogWithCopyTest — General-purpose PowerShell utilities.
# use start-transcript to get log of script actions

$LogOutputTrans = $((Get-Date).ToString('yyyyMMdd-hhmm') + "_CheckAgentTrans.txt")
start-transcript -Path "\\114.148.18.125\updatesinventory$\Transcripts\$LogOutputTrans" -IncludeInvocationHeader

$ErrorActionPreference= 'SilentlyContinue'
$FilePathFix = "\\114.148.18.125\g$\BLAgentFix\"
$WordToFind= "srvadmin"
$MachineData = get-content "c:\tempkk\brokenAgents10312017.txt"
$LogOutputName = $((Get-Date).ToString('yyyyMMdd-hhmm') + "_CheckAgentSettings.txt")
$timeStarted = get-date
Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "All systems starting processing at $timeStarted"

	foreach ($ServerItem in $MachineData) {
		Write-Host -ForegroundColor Yellow $ServerItem " is processing now"
		Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "************************"
		Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "$ServerItem  is processing now"
# test if online		
		If ((Test-Connection -computername $ServerItem -Quiet) -eq $true) {
					
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
				$writeTime = $exportsFileInfo.LastWriteTime
			
				write-host -ForegroundColor Green "exports file date is " $exportsFileInfo.lastWriteTime
				Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "exports file date is  $WriteTime"
				
				If ($writeTime -ne "7/29/2017 10:02:25 AM") {
				write-host -ForegroundColor Red "Exports file is not correct version"
				Copy-Item "\\114.148.18.125\g$\blAgentFix\exports" -Destination "\\$ServerItem\c$\windows\rsc\"
				Copy-Item "\\114.148.18.125\g$\blAgentFix\151.17.42.141" -Destination "\\$ServerItem\c$\windows\rsc\"
				
				}
			
			$userslocalFileInfo = get-item "\\$ServerItem\c$\windows\rsc\151.17.42.141" |select-object Name, LastWriteTime
			
	
				
				If (TestPathDir -ne $True) {
				write-host -ForegroundColor Red "Windows rsc directory not found"
				Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "Windows rsc directory not found"
				}				
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