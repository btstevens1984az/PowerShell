# Purpose: Fix-agent9 — General-purpose PowerShell utilities.
$ErrorActionPreference= 'SilentlyContinue'
$FilePathFix = "C:\bladelogic\"
$WordToFind= "srvadmin"
$MachineData = get-content "c:\BLadeLogic\group10install.txt"

	foreach ($ServerItem in $MachineData) {
		Write-Host -ForegroundColor Yellow $ServerItem " is processing now"
# test if online		
		If ((Test-Connection -computername $ServerItem -Quiet) -eq $true) {
		    Copy-Item "C:\BladeLogic\Agent9Upgrade\" -Destination "\\$ServerItem\c$\tmp\Agent9Upgrade\" -Recurse
				# Copy-Item "C:\BladeLogic\Agent9Upgrade" -Destination "\\$ServerItem\c$\temp\"
				
				Write-Host -ForegroundColor GREEN "$serveritem files copied"
           
}
		   Else { 
				Write-Host -ForegroundColor RED $ServerItem "NOT ONLINE"
						
				}
			
			}
Write-Host -ForegroundColor GREEN "All systems have completed processing"
$timeCompleted = get-date