# Purpose: ChangeCustomToSatelliteFSS002 — General-purpose PowerShell utilities.
$LogOutputTrans = $((Get-Date).ToString('yyyyMMdd-hhmm') + "_ChangeCustomSettingsTo-35.130.175.52.txt")
start-transcript -Path "\\114.148.18.125\I$\ControlChange\JobLog\$LogOutputTrans" -IncludeInvocationHeader

$ErrorActionPreference = 'SilentlyContinue'

#test copy to verify all FSS servers in list get the file

# copies CustomSettings with 114.148.18.125 defined as reference
write-host -foregroundcolor Yellow "This will overwrite the customsettings file to point to 173.191.4.186."

# force user to confirm continuing
#Write-Host "Press enter to continue and CTRL-C to exit ..."
#$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

#list of targets - this should include all FSS servers that should get the new CustomSettings.ini file

$computers = gc "\\114.148.18.125\I$\ControlChange\FSSservers.txt"
 
# really just used in testing. as file name is the same for both 002 or 003
$File2Copy= "CustomSettings.ini"
 
# This is the file you want to copy to the servers in the $computer variable
$source = "\\114.148.18.125\I$\ControlChange\FSS002\CustomSettings.ini"
 
# The destination location you want the file to be copied to
$destination = "MDT\Deploy\Control\"
 
 
#The command below pulls all the variables above and performs the file copy
	foreach ($Computer in $Computers) {
		If ((Test-Connection -computername $Computer -Quiet) -eq $true) {
		
		Copy-Item $source -Destination "\\$computer\$destination" -force
		
		$NewFile= Test-Path "\\$computer\mdt\deploy\control\$file2copy"
			If ($NewFile -eq $True)
				write-host -ForegroundColor Green "$computer\mdt\deploy\control\$file2copy"
			If ($NewFile -ne $True)
				write-host -ForegroundColor Red "No file found on $computer\mdt\deploy\control\$file2copy"
		}
	Else { 
				Write-Host -ForegroundColor RED $Computer "NOT ONLINE"
				Add-Content \\114.148.18.125\I$\ControlChange\JobLog\$LogOutputTrans\$LogOutputTrans"  "$ServerItem not online No further processing done"			
				}	
}

write-host -ForegroundColor Green "All systems processed"

$timeCompleted = get-date
Add-Content "\\114.148.18.125\I$\ControlChange\JobLog\$LogOutputTrans\$LogOutputTrans" "All systems have completed processing $timeCompleted"
stop-transcript