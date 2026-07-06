# Purpose: IECleanup — General-purpose PowerShell utilities.
function IECleanup ()
{
	## Function for clearing IE Cache/Cookies. 
	## Does NOT delete saved passwords.
	Write-Host "Deleting IE Cookies/cache..." -ForegroundColor Yellow
	function Clear-IECachedData
	{
		## 20160418.jomeyer.Organized and added options
		if ($History) { RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 1 }
		if ($Cookies) { RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 2 }
		if ($TempIEFiles) { RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 4 }
		if ($OfflineTempFiles) { RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 8 }
		if ($FormData) { RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 16 }
		if ($All) { RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 255 }
		if ($AddOn) { RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 4096 }
		if ($AllplusAddOn) { RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 4351 }
	}
	do
	{
		## Calls function to perform the action.
		## 20160418.jomeyer.Clearing more cached data
		## 20170126.jmeyer.Removed "AllplusAddOn". This deleted Passwords.
		$continue2 = $true
		& Clear-IECachedData -History -Cookies -TempIEFiles -OfflineTempFiles -FormData -AddOn
	}
	While ($continue2 -eq $false)
	Write-Host "Completed!" -ForegroundColor Green
}