# Purpose: Get-TunerVersion — Reusable PowerShell function libraries.
# use start-transcript to get log of script actions
# get date just adds start and stop times to give an idea of runtime

Function Get-TunerVersion {
$LogOutputTrans = $((Get-Date).ToString('yyyyMMdd-hhmm') + "_TunerVersion.txt")
start-transcript -Path "U:\Functions\$LogOutputTrans" -IncludeInvocationHeader

$ErrorActionPreference= 'SilentlyContinue'

# change path to list of machines to check.. or add dynamic
# log paths can be changed ot another share or dir more easily accessed
$MachineData = get-content "c:\temp\TunerListAD.txt"
$LogOutputName = $((Get-Date).ToString('yyyyMMdd-hhmm') + "_CheckTunerVersionAD.txt")
$LogOutputName2 = $((Get-Date).ToString('yyyyMMdd-hhmm') + "_TunerVersionsAD.txt")
$LogOutputName3 = $((Get-Date).ToString('yyyyMMdd-hhmm') + "_TunerVersion-9-onlyAD.txt")

# should add logic to exclude empty tuner checks.. so list only shows version 8. 
$LogOutputName4 = $((Get-Date).ToString('yyyyMMdd-hhmm') + "_TunerVerNOT9NOTfoundAD.txt")
$timeStarted = get-date

Add-Content "U:\Functions\$LogOutputName" "All systems starting processing at $timeStarted"

	foreach ($ServerItem in $MachineData) {
		Write-Host -ForegroundColor Yellow $ServerItem " is processing now"
		Add-Content "U:\Functions\$LogOutputName" "************************"
		Add-Content "U:\Functions\$LogOutputName" "$ServerItem  is processing now"
		
		If ((Test-Connection -computername $ServerItem -Quiet) -eq $true) {
		write-host -ForegroundColor Green $serveritem is online
		Add-Content "U:\Functions\$LogOutputName" "$ServerItem  is online"
	
		$TestPathDir = test-path "\\$ServerItem\c$\Program Files (x86)\Marimba\Castanet Tuner"
			
			If ($TestPathDir -eq $True) {
				write-host -ForegroundColor Green Windows Tuner directory exists on $serveritem
				Add-Content "U:\Functions\$LogOutputName" "\\$ServerItem\c$\Program Files (x86)\Marimba\Castanet Tuner was found"
			
			$TunerFileInfo = (get-item "\\$ServerItem\c$\Program Files (x86)\Marimba\Castanet Tuner\tuner.exe").VersionInfo.FileVersion
			
				write-host -ForegroundColor Green "$serverItem Tuner.exe file version is " $TunerFileInfo
				Add-Content "U:\Functions\$LogOutputName" "$serverItem Tuner.exe file version is  $TunerFileInfo"
				Add-Content "U:\Functions\$LogOutputName2" "$serverItem Tuner.exe file version is  $TunerFileInfo"

				If ($TunerFileInfo -eq "9.0.03") {
				write-host -ForegroundColor Green "Tuner 9.0.03 found on $serverItem"
				Add-Content "U:\Functions\$LogOutputName3" "$serverItem $tunerfileInfo"
				}	
		
				If ($TunerFileInfo -ne "9.0.03") {
				write-host -ForegroundColor Red "Tuner 9.0.03 NOT found on $serverItem"
				Add-Content "U:\Functions\$LogOutputName4" "$serverItem $tunerfileInfo"
				}
		
				If ($TestPathDir -ne $True) {
				write-host -ForegroundColor Red "Tuner directory not found"
				Add-Content "U:\Functions\$LogOutputName" "Tuner directory not found on $serverItem"
				}				
            }
	}
		
	Else { 
				Write-Host -ForegroundColor RED $ServerItem "NOT ONLINE"
				Add-Content "U:\Functions\$LogOutputName"  "$ServerItem not online No further processing done"			
				}
			Write-Host -ForegroundColor Yellow $ServerItem Completed 
			Write-Host "     Next System        "
			Add-Content "U:\Functions\$LogOutputName" " $ServerItem Completed "
			Add-Content "U:\Functions\$LogOutputName" " "
}
Write-Host -ForegroundColor GREEN "All systems have completed processing"
$timeCompleted = get-date
Add-Content "U:\Functions\$LogOutputName" "All systems have completed processing $timeCompleted"
stop-transcript
}