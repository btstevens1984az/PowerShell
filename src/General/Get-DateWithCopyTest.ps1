# Purpose: Get-DateWithCopyTest — General-purpose PowerShell utilities.
$LogOutputTrans = $((Get-Date).ToString('yyyyMMdd-hhmm') + "_CheckAgentTrans.txt")

$ErrorActionPreference= 'SilentlyContinue'
$FilePathFix = "\\114.148.18.125\g$\BLAgentFix\"
$WordToFind= "srvadmin"
$MachineData = get-content "c:\tempkk\brokenAgents10312017.txt"
$LogOutputName = $((Get-Date).ToString('yyyyMMdd-hhmm') + "_CheckAgentSettings.txt")
$timeStarted = get-date

Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "All systems starting processing at $timeStarted"

	foreach ($ServerItem in $MachineData) {
		Write-Host -ForegroundColor Yellow $ServerItem " is processing now"

# test if online		
		If ((Test-Connection -computername $ServerItem -Quiet) -eq $true) {

		$TestPathDir = test-path "\\$ServerItem\c$\windows\rsc"
			
			If ($TestPathDir -eq $True) {
				write-host -ForegroundColor Green Windows rsc directory exists
			
			$exportsFileInfo = get-item "\\$ServerItem\c$\windows\rsc\exports" |select-object Name, LastWriteTime
				$writeTime = $exportsFileInfo.LastWriteTime.date
			
				write-host -ForegroundColor Green "exports file date is " $exportsFileInfo.lastWriteTime.date
				
				If ($writeTime -ne "7/29/2017") {
				write-host -ForegroundColor Red "Exports file is not correct version" $writeTime
				# Copy-Item "\\114.148.18.125\g$\blAgentFix\exports" -Destination "\\$ServerItem\c$\windows\rsc\"
				# Copy-Item "\\114.148.18.125\g$\blAgentFix\151.17.42.141" -Destination "\\$ServerItem\c$\windows\rsc\"
				}
				
				If ($writeTime -eq "7/29/2017") {
				write-host -ForegroundColor Green "Exports file is the correct version" $writeTime
				# Copy-Item "\\114.148.18.125\g$\blAgentFix\exports" -Destination "\\$ServerItem\c$\windows\rsc\"
				# Copy-Item "\\114.148.18.125\g$\blAgentFix\151.17.42.141" -Destination "\\$ServerItem\c$\windows\rsc\"
				}
				}				
            }
	
		
		Else { 
				Write-Host -ForegroundColor RED $ServerItem "NOT ONLINE"
						
				}
			Write-Host -ForegroundColor Yellow $ServerItem Completed 
		Write-Host "     Next System        "
}

Write-Host -ForegroundColor GREEN "All systems have completed processing"
$timeCompleted = get-date