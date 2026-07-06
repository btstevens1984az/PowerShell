# Purpose: Install-agent9 — PowerShell automation.
$ErrorActionPreference= 'SilentlyContinue'
# $FilePathFix = "C:\bladelogic\"
# $WordToFind= "srvadmin"
$MachineData = get-content "c:\BLadeLogic\group10install.txt"

$timeStarted = get-date
Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "All systems starting processing at $timeStarted"

	foreach ($ServerItem in $MachineData) {
		Write-Host -ForegroundColor Yellow $ServerItem " is processing now"
		
		If ((Test-Connection -computername $ServerItem -Quiet) -eq $true) {
		
# checks to see if 64 bit prgram file dir is in place	
		$TestPathDir = test-path "\\$ServerItem\c$\Program Files (x86)"
			
			If ($TestPathDir -eq $True) {
				write-host -ForegroundColor Green "Windows is 64 bit"
				psexec -s -d -accepteula \\$ServerItem msiexec /package "c:\tmp\Agent9Upgrade\windows_64\RSCD89-SP1-WIN64.msi" /quiet /norestart

				}
			If ($TestPathDir -eq $False) {
				
				psexec -s -d -accepteula \\$ServerItem msiexec /package "c:\tmp\Agent9Upgrade\windows_32\RSCD89-SP1-WIN32.msi" /quiet /norestart
				write-host -ForegroundColor Green "Windows is 32 bit"
	
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
