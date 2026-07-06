# Purpose: ChromeCleanup — General-purpose PowerShell utilities.
function ChromeCleanup ()
{
	## 20160510.jomeyer.Added Chrome cleanup
	Write-Host "Checking to see if Chrome is installed..." -ForegroundColor Yellow
	if ($Chrome -eq $true)
	{
		Write-Host "Chrome is installed." -ForegroundColor Green
		Write-Host "Deleting Chrome cache..." -ForegroundColor Yellow
		
		$ChromeDIR = "$UserDir\Local\Google\Chrome"
		
		Remove-Item -Path "$ChromeDIR\User Data\Default\*journal" -Force -Recurse
		Remove-Item -Path "$ChromeDIR\User Data\Default\Cookies" -Force -Recurse
		Remove-Item -Path "$ChromeDIR\User Data\Default\Cache\*" -Force -Recurse
		Remove-Item -Path "$ChromeDIR\User Data\Default\Storage\ext\*" -Force -Recurse
		Remove-Item -Path "$ChromeDIR\User Data\Default\Media Cache\*" -Force -Recurse
		Remove-Item -Path "$ChromeDIR\User Data\Default\GPUCache\*" -Force -Recurse
		Remove-Item -Path "$ChromeDIR\User Data\Default\Application Cache\Cache\*" -Force -Recurse
		Remove-Item -Path "$ChromeDIR\User Data\Default\File System\*" -Force -Recurse
		Remove-Item -Path "$ChromeDIR\User Data\Default\Service Worker\*" -Force -Recurse
		Remove-Item -Path "$ChromeDIR\User Data\Default\JumpListIcons\*" -Force -Recurse
		Remove-Item -Path "$ChromeDIR\User Data\Default\JumpListIconsOld\*" -Force -Recurse
		Remove-Item -Path "$ChromeDIR\User Data\Default\Local Storage\*" -Force -Recurse
		Remove-Item -Path "$ChromeDIR\User Data\Default\IndexedDB\*" -Force -Recurse
		Remove-Item -Path "$ChromeDIR\User Data\ShaderCache\GPUCache\*" -Force -Recurse
		Remove-Item -Path "$ChromeDIR\User Data\Default\Pepper Data\Shockwave Flash\WritableRoot\*" -Force -Recurse
		Remove-Item -Path "$ChromeDIR\ShaderCache\GPUCache\*" -Force -Recurse
		Write-Host "Completed!" -ForegroundColor Green
	}
	else
	{
		Write-Host "Cannot find Google Chrome." -ForegroundColor Red
	}
}
