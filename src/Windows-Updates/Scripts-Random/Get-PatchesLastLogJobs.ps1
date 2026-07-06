# Purpose: Get-PatchesLastLogJobs — Windows Update and patch management.
# use start-transcript to get log of script actions

$LogOutputTrans = $((Get-Date).ToString('yyyyMMdd-hhmm') + "_LatestPatch.txt")
start-transcript -Path "\\75.87.199.36\updatesinventory$\Transcripts\$LogOutputTrans" -IncludeInvocationHeader



$ErrorActionPreference= 'SilentlyContinue'

$MachineData = get-content "c:\psdev\BLA-Check.txt"
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

Write-Host -ForegroundColor GREEN "All systems have completed processing"
$timeCompleted = get-date
Add-Content "\\75.87.199.36\UpdatesInventory$\$LogOutputName" "All systems have completed processing $timeCompleted"
stop-transcript