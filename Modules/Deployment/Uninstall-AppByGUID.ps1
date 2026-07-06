# Purpose: Uninstall-AppByGUID — Reusable PowerShell function libraries.
Function Uninstall-AppByGUID
{
	PARAM (
		[string]$GUID
	)
	$Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{" + $GUID + "}"
	if(Test-Path $Key)
	{
		$Application = Get-ItemProperty $Key | Select DisplayName, InstallLocation, UninstallString
		$temp = ($Application.UninstallString).Split(' ')
		[string]$process = $temp[0]
		[string]$arg = $temp[1]
		Write-Host "Uninstalling"$Application.DisplayName
		$Uninstall = Start-Process "$process" -argumentlist "$arg /qn" -wait -verb runas
		Invoke-Expression "$Uninstall"
		if (Test-Path $Application.InstallLocation)
		{
			Write-Host "Cleaning up"$Application.InstallLocation
		}
		if($Uninstall.exitcode -eq 0 )
		{
			Write-Host "Successfully uninstalled"$Application.DisplayName
		}
	}
	else
	{
		Write-Host "Unable to locate uninstall string from"$Key
	}
}