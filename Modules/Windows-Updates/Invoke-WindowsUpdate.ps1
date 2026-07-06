# Purpose: Invoke-WindowsUpdate — Windows Update and patch management.
function Invoke-WindowsUpdate
{

	param
	(
		[Parameter(Mandatory=$false)]
		[bool] $NoRestart = $false
	)

	# based on http://www.gregorystrike.com/2011/04/07/force-windows-automatic-updates-with-powershell/

	$ErrorActionPreference = "Stop";
	Set-StrictMode -Version "Latest";

	Write-DebugText "********************";
	Write-DebugText "Invoke-WindowsUpdate";
	Write-DebugText "********************";

	# query available updates
	Write-DebugText "querying available updates";
	$session = new-object -com Microsoft.Update.Session;
	$searcher = $session.CreateUpdateSearcher();
	$searcherResult = $searcher.Search("IsInstalled=0 and Type='Software' and IsHidden=0");
	Write-DebugText "    $($searcherResult.Updates.Count) update(s) found";

	if( $searcherResult.Updates.Count -eq 0 )
	{
		Write-DebugText "no updates to install";
		return;
	}

	# download updates
	Write-DebugText "downloading updates";
	for( $i = 0; $i -lt $searcherResult.Updates.Count; $i++ )
	{
		$update = $searcherResult.Updates.Item($i);
		Write-DebugText "    downloading $($i+1) of $($searcherResult.Updates.Count) - $($update.Title)";
		if( $update.IsDownloaded )
		{
			Write-DebugText "        already downloaded";
			Write-DebugText "        skipping download";
		}
		else
		{
			Write-DebugText "        preparing download";
			$downloads = new-object -com Microsoft.Update.UpdateColl;
			[void] $downloads.Add($update);
			$downloader = $session.CreateUpdateDownloader();
			$downloader.Updates = $downloads;
			Write-DebugText "        invoking download";
			[void] $downloader.Download();
			Write-DebugText "        download complete";
		}
	}

	# see http://support.microsoft.com/kb/836941

	# error constants from http://support.microsoft.com/kb/938205
	[int] $WU_ERROR_INTERNET_TIMEOUT         = 0x80072EE2; # The request has timed out.
	[int] $WU_E_EULAS_DECLINED               = 0x80240023; # The license terms for all updates were declined.
	[int] $WU_E_NO_UPDATE                    = 0x80240024; # There are no updates.
	[int] $WU_E_UNKNOWN_SERVICE              = 0x80240042; # The update service is no longer registered with AU.
	[int] $WU_E_PT_WINHTTP_NAME_NOT_RESOLVED = 0x8024402C; # Same as ERROR_WINHTTP_NAME_NOT_RESOLVED - the proxy server or target server name cannot be resolved.

	# install updates
	$rebootRequired = $false;
	Write-DebugText "installing updates";
	for( $i = 0; $i -lt $searcherResult.Updates.Count; $i++ )
	{
		Write-DebugText "    installing $($i+1) of $($searcherResult.Updates.Count) - $($update.Title)";
		$update = $searcherResult.Updates.Item($i);
		if( $update.IsDownloaded )
		{
			Write-DebugText "        preparing installer";
			if( -not $update.EulaAccepted )
			{
				$update.AcceptEULA();
			}
			$installs = new-object -com Microsoft.Update.UpdateColl;
			[void] $installs.Add($update);
			$installer = $session.CreateUpdateInstaller();
			$installer.ForceQuiet = $true;
			$installer.Updates = $installs;
			Write-DebugText "        invoking installer";
			$installerResult = $installer.Install();
			Write-DebugText "        install complete";
			$rebootRequired = $rebootRequired -or $installerResult.RebootRequired;
		}
	}
	if( $rebootRequired )
	{
		$reboot = Get-WMIObject -Class Win32_OperatingSystem;
		$reboot.PSBase.Scope.Options.EnablePrivileges = $true;
		[void] $reboot.Reboot();
		while( $true )
		{
			Write-DebugText "waiting for reboot...";
			Start-Sleep -Milliseconds 2500;
		}
	}

}