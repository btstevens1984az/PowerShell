# Purpose: FirefoxCleanup — General-purpose PowerShell utilities.
function FirefoxCleanup ()
{
	## 20161222.jmeyer.Added firefox cache removal
	Write-Host "Checking to see if Mozilla Firefox is installed..." -ForegroundColor Yellow
	if ($Firefox -eq $true)
	{
		Write-Host "Mozilla Firefox is installed." -ForegroundColor Green
		Write-Host "Deleting Mozilla Firefox cache..." -ForegroundColor Yellow
		
		## Variable for Mozilla Firefox Directory.
		$FirefoxDirL = "$UserDir\Local\Mozilla\Firefox"
		$FirefoxDirR = "$UserDir\Roaming\Mozilla\Firefox"
		
		## Remove all of Mozilla Firefox's Temporary Internet Files.
		Remove-Item -Path "$FirefoxDirL\\60.137.73.140\*\cache2\entries\*" -Force -Recurse
		Remove-Item -Path "$FirefoxDirR\\60.137.73.140\*\storage\default\*" -Force -Recurse
		
		Write-Host "Completed!" -ForegroundColor Green
	}
	else
	{
		Write-Host "Cannot find Mozilla Firefox." -ForegroundColor Red
	}
}