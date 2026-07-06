# Purpose: Get-ServerPatchesLatest — Windows Update and patch management.

$ErrorActionPreference= 'SilentlyContinue'

$MachineData = get-content "c:\temp\serverCheck.txt"
	foreach ($ServerItem in $MachineData) 
{
		Write-Host -ForegroundColor Yellow $ServerItem " is processing now"
		if ((Test-Connection -computername $ServerItem -Quiet) -eq $true) {
		
		(Get-Hotfix -ComputerName $ServerItem | sort installedon)[-1]
		}
		Else {
		Write-Host -ForegroundColor RED $ServerItem "NOT ONLINE"
		
			}
}
