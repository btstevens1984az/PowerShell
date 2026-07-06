# Purpose: Get-ServerPatches — Windows Update and patch management.

$ErrorActionPreference= 'SilentlyContinue'

$MachineData = get-content "c:\tempkk\computers2.txt"
	foreach ($ServerItem in $MachineData) 
{
		Write-Host -ForegroundColor Yellow $ServerItem " is processing now"
		if ((Test-Connection -computername $ServerItem -Quiet) -eq $true) {
		
		Get-Hotfix -ComputerName $ServerItem | Select PSComputerName, HotfixID, Description, InstalledOn, InstalledBy, Caption | export-csv -append \\75.87.199.36\UpdatesInventory$\OctoberInv-Test\October2017InventoryTest3.csv -notypeinformation
		Write-Host -ForegroundColor Green $ServerItem Completed 
		}
		Else {
		Write-Host -ForegroundColor RED $ServerItem "NOT ONLINE"
		Add-Content '\\75.87.199.36\UpdatesInventory$\OctoberInv-Test\October2017InventoryTest3Offline.txt' $ServerItem
			}
}

Write-Host -ForegroundColor GREEN "All systems have completed processing"