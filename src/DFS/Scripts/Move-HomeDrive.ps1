# Purpose: Move-HomeDrive — PowerShell automation.
param($NoExit)

# restart PowerShell with -noexit, the same script, and 1
if (!$NoExit) {
	$Host.UI.RawUI.BackgroundColor = "Black"
	Clear-Host
    PowerShell -NoExit -File $MyInvocation.MyCommand.Path 1
    return
}
#region DLLImport
Add-Type -TypeDefinition @" 
using System;
using System.Collections; 
using System.Runtime.InteropServices;

public class NetApi32 
{
	[DllImport("Netapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
	public static extern int NetDfsGetInfo
		(
		[MarshalAs(UnmanagedType.LPWStr)] string EntryPath,
		[MarshalAs(UnmanagedType.LPWStr)] string ServerName,
		[MarshalAs(UnmanagedType.LPWStr)] string ShareName,
		int Level,
		ref IntPtr Buffer
		);

	[DllImport("Netapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
	public static extern int NetApiBufferFree(IntPtr Buffer);

	[DllImport("Netapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
	public static extern int NetShareGetInfo
		(
		[MarshalAs(UnmanagedType.LPWStr)] string serverName,
		[MarshalAs(UnmanagedType.LPWStr)] string netName,
		Int32 level,
		out IntPtr bufPtr
		);

	[DllImport("Netapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
	public static extern int NetDfsAdd
		(
		[MarshalAs(UnmanagedType.LPWStr)] string DfsEntryPath,
		[MarshalAs(UnmanagedType.LPWStr)] string ServerName,
		[MarshalAs(UnmanagedType.LPWStr)] string PathName,
		[MarshalAs(UnmanagedType.LPWStr)] string Comment,
		int Flags
		);

	[DllImport("Netapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
	public static extern int NetDfsRemove
		(
		[MarshalAs(UnmanagedType.LPWStr)] string DfsEntryPath,
		[MarshalAs(UnmanagedType.LPWStr)] string ServerName,
		[MarshalAs(UnmanagedType.LPWStr)] string ShareName
		);

	[DllImport("Netapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
	public static extern int NetServerGetInfo
		(
		string serverName, 
		int level, 
		out IntPtr pSERVER_INFO_XXX
		);

	[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
	public struct DFS_INFO_3
	{
		[MarshalAs(UnmanagedType.LPWStr)]
		public string EntryPath;
		[MarshalAs(UnmanagedType.LPWStr)]
		public string Comment;
		public UInt32 State;
		public UInt32 NumberOfStorages;
		public IntPtr Storages;
	}
	[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
	public struct DFS_STORAGE_INFO
	{
		public Int32 State;
		[MarshalAs(UnmanagedType.LPWStr)]
		public string ServerName;
		[MarshalAs(UnmanagedType.LPWStr)]
		public string ShareName;
	}
	[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
	public struct SHARE_INFO_502
	{
		[MarshalAs(UnmanagedType.LPWStr)] public string shi502_netname;
		public uint shi502_type;
		[MarshalAs(UnmanagedType.LPWStr)] public string shi502_remark;
		public Int32 shi502_permissions;
		public Int32 shi502_max_uses;
		public Int32 shi502_current_uses;
		[MarshalAs(UnmanagedType.LPWStr)] public string shi502_path;
		public IntPtr shi502_passwd;
		public Int32 shi502_reserved;
		public IntPtr shi502_security_descriptor;
	}
	[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
	public struct SERVER_INFO_101
	{
		public int PlatformId;
		[MarshalAs(UnmanagedType.LPTStr)] public string Name;
		public int VersionMajor;
		public int VersionMinor;
		public int Type;
		[MarshalAs(UnmanagedType.LPTStr)] public string Comment;
	}
	public static ArrayList GetDFSLinkInfo(string sDFSPath)
	{
		ArrayList sServers = new ArrayList();
		IntPtr pBuffer = new IntPtr();
		int iResult = NetDfsGetInfo(sDFSPath, null, null, 3, ref pBuffer);
		if (iResult == 0)
		{

			DFS_INFO_3 oDFSInfo = (DFS_INFO_3)Marshal.PtrToStructure(pBuffer, typeof(DFS_INFO_3));
			NetApiBufferFree(pBuffer);
			for (int i = 0; i < oDFSInfo.NumberOfStorages; i++)
			{
				IntPtr pStorage = new IntPtr(oDFSInfo.Storages.ToInt64() + i * Marshal.SizeOf(typeof(DFS_STORAGE_INFO)));
				DFS_STORAGE_INFO oStorageInfo = (DFS_STORAGE_INFO)Marshal.PtrToStructure(pStorage, typeof(DFS_STORAGE_INFO));

				//Get Only Active Hosts
				//if (oStorageInfo.State == 2)
				//{
					sServers.Add(oStorageInfo);
				//}
			}
			return sServers;
		}
		else
			sServers.Add(iResult);
			return sServers;
	}
	public static ArrayList GetShareInfo(string sServerName,string sShareName)
	{
		ArrayList sInfo = new ArrayList();
		IntPtr pBuffer = new IntPtr();
		int iResult = NetShareGetInfo(sServerName, sShareName, 502, out pBuffer);
		if (iResult == 0)
		{
			SHARE_INFO_502 oShareInfo = (SHARE_INFO_502)Marshal.PtrToStructure(pBuffer, typeof(SHARE_INFO_502));
			NetApiBufferFree(pBuffer);
			sInfo.Add(oShareInfo);
		}
		return sInfo;
	}
	public static ArrayList GetServerInfo(string sServerName)
	{
		ArrayList sInfo = new ArrayList();
		IntPtr pBuffer = new IntPtr();
		int iResult = NetServerGetInfo(sServerName, 101, out pBuffer);
		if (iResult == 0)
		{
			SERVER_INFO_101 oServerInfo = (SERVER_INFO_101)Marshal.PtrToStructure(pBuffer, typeof(SERVER_INFO_101));
			NetApiBufferFree(pBuffer);
			sInfo.Add(oServerInfo);
		}
		return sInfo;
	}
}
"@
#endregion

function InitialPhase {
	param($SourceDirectoriesArray,$Destination)
	$ParentDirectory = [System.IO.Directory]::GetParent($Destination)
	$i = 0
	foreach ($SourceDirectory in $SourceDirectoriesArray) {
		$User = $SourceDirectory.Split("\")[-1]
		Write-Progress -Activity "Creating directories and assigning permissions" -PercentComplete (($i / $($SourceDirectoriesArray.Count)) * 100) -CurrentOperation $User
		$i++
		$SourceDirectoryACL = New-Object System.Security.AccessControl.DirectorySecurity -ArgumentList $SourceDirectory,"Access"
		$SourceDirectoryPermissions = $SourceDirectoryACL.GetAccessRules($true, $false, [System.Security.Principal.SecurityIdentifier])
		$DestinationDirectory = $ParentDirectory.CreateSubdirectory($User)
		$DestinationDirectoryACL = $DestinationDirectory.GetAccessControl()
		$DestinationDirectoryPermissions = $DestinationDirectoryACL.GetAccessRules($true, $false, [System.Security.Principal.SecurityIdentifier])
		$PermissionsComparison = $null
		$PermissionsComparison = Compare-Object $SourceDirectoryPermissions $DestinationDirectoryPermissions
		if ($PermissionsComparison -ne $null) {
			foreach ($Rule in $SourceDirectoryPermissions) {
				$DestinationDirectoryACL.AddAccessRule($Rule)
			}
			$DestinationDirectory.SetAccessControl($DestinationDirectoryACL)
		}
	}
	Write-Progress -Activity "Creating directories and assigning permissions" -Completed
	$i = 0
	foreach ($SourceDirectory in $SourceDirectoriesArray) {
		$Date = Get-Date -Format MMddyyyy_HHmm
		$User = $SourceDirectory.Split("\")[-1]
		$DestinationDirectory = $Destination + $User
		$LogFile = "\\87.43.232.114\Home and Group Folders\Home_Group Folder Project\HDriveMoveLogs\" + $User + "_" + $Date + ".log"
		Write-Progress -Activity "Running robocopy" -PercentComplete (($i / $($SourceDirectoriesArray.Count)) * 100) -CurrentOperation $User
		$i++
		$RobocopyReturn = Start-Process -FilePath 'C:\Windows\System32\Robocopy.exe' -ArgumentList "$SourceDirectory $DestinationDirectory /MIR /COPY:DAT /DCOPY:T /XF autorun.inf desktop.ini thumbs.db /XD `$Recycle.Bin RECYCLER /R:0 /MT:16 /LOG:`"$LogFile`"" -WorkingDirectory 'C:\Windows\System32' -Wait -WindowStyle 'Hidden' -PassThru
		[System.IO.File]::AppendAllText($script:RoboCopyReturnFile, "$User,$SourceDirectory,$DestinationDirectory,$($RobocopyReturn.ExitCode)" + [System.Environment]::NewLine)
	}
	Write-Progress -Activity "Running robocopy" -Completed
}

function FinalPhase {
	param($SourceDirectoriesArray,$Destination)
	InitialPhase -SourceDirectoriesArray $SourceDirectoriesArray -Destination $Destination
	$i = 0
	foreach ($SourceDirectory in $SourceDirectoriesArray) {
		$User = $SourceDirectory.Split("\")[-1]
		$DestinationDirectory = $Destination + $User
		Write-Progress -Activity "Updating DFS links" -PercentComplete (($i / $($SourceDirectoriesArray.Count)) * 100) -CurrentOperation $User
		$i++
		$TargetInfo = [NetApi32]::GetDFSLinkInfo("\\186.189.182.154\share\logs")
		if ($TargetInfo.Count -eq 1) { # The count of the returned C# ArrayList will be one and...
			if ($TargetInfo[0] -is [Int32]) { # The value will be an Int32 if there was an error returned.
				if ($TargetInfo[0] -eq 1168) {
					# 1168 is ERROR_NOT_FOUND. Element not found.
					# 5 is ERROR_ACCESS_DENIED. Access is denied.
					$script:ErrorCount++
					[System.IO.File]::AppendAllText($script:ErrorFile, "$User,$SourceDirectory,$DestinationDirectory,NoDFSLink,1168" + [System.Environment]::NewLine)
					continue
				}
				else {
					$script:ErrorCount++
					$ErrorMessage = "An unknown error occurred while attempting to access DFS. The error code was: $($TargetInfo[0]). Stopping script. Press any key to exit.
					More info at http://msdn.microsoft.com/en-us/library/windows/desktop/ms681381(v=vs.85).aspx"
					[System.IO.File]::AppendAllText($script:ErrorFile, "$User,$SourceDirectory,$DestinationDirectory,Catastrophic,$($TargetInfo[0])" + [System.Environment]::NewLine)
					throw $ErrorMessage
				}
			}
			else {
				$TargetInfo = $TargetInfo[0] # Had to add [0] due to ArrayList return
			}
		}
		else {
			# More than one DFS link via folder name.
			$script:ErrorCount++
			$DFSTargets = [String]""
			for ($i=0; $i -lt $TargetInfo.Count; $i++) {
				$DFSTargets += "\\$($TargetInfo[$i].ServerName)\$($TargetInfo[$i].ShareName);"
			}
			[System.IO.File]::AppendAllText($script:ErrorFile, "$User,$SourceDirectory,$DestinationDirectory,MultipleTargets,$DFSTargets" + [System.Environment]::NewLine)
			continue
		}
		$DFSTarget = "\\$($TargetInfo.ServerName)\$($TargetInfo.ShareName)"
		if ($DFSTarget -eq $SourceDirectory) {
			Write-Host "Change $User from $SourceDirectory to $DestinationDirectory"
			[URI]$DestinationURI = $DestinationDirectory
			[URI]$SourceURI = $SourceDirectory
			$DFSAddReturn = [NetApi32]::NetDfsAdd("\\186.189.182.154\share\logs",$($DestinationURI.Host.ToUpper()),$($DestinationURI.AbsolutePath.Replace("/","\").TrimStart("\")),$null,0)
			if ($DFSAddReturn -ne 0) {
				$script:ErrorCount++
				[System.IO.File]::AppendAllText($script:ErrorFile, "$User,$SourceDirectory,$DestinationDirectory,ErrorAddingNewTarget,$DFSAddReturn" + [System.Environment]::NewLine)
				continue
			}
			$DFSRemoveReturn = [NetApi32]::NetDfsRemove("\\186.189.182.154\share\logs",$($SourceURI.Host.ToUpper()),$($SourceURI.AbsolutePath.Replace("/","\").TrimStart("\")))
			if ($DFSRemoveReturn -ne 0) {
				$script:ErrorCount++
				[System.IO.File]::AppendAllText($script:ErrorFile, "$User,$SourceDirectory,$DestinationDirectory,ErrorRemovingOldTarget,$DFSRemoveReturn" + [System.Environment]::NewLine)
				continue	
			}
			if ($DFSAddReturn -eq 0 -and $DFSRemoveReturn -eq 0) {
				[System.IO.File]::AppendAllText("\\87.43.232.114\Home and Group Folders\Home_Group Folder Project\HDriveMoveLogs\DFSLinks.csv", "$User,$SourceDirectory,$DestinationDirectory,$([DateTime]::Now.ToString())" + [System.Environment]::NewLine)
			}
		}
		else {
			# DFS link target doesn't match source destination directory
			$script:ErrorCount++
			[System.IO.File]::AppendAllText($script:ErrorFile, "$User,$SourceDirectory,$DestinationDirectory,DifferentTarget,$DFSTarget" + [System.Environment]::NewLine)
			Write-Host "Not changing $User from $SourceDirectory to $DestinationDirectory because it doesn't match $DFSTarget"
		}
	}
	Write-Progress -Activity "Updating DFS links" -Completed
}
$script:ErrorCount = 0
$script:ErrorFileDirectory = "C:\Temp\MoveHDrive\"
if ((Test-Path $script:ErrorFileDirectory) -eq $false) {New-Item -Path $script:ErrorFileDirectory -Type Directory | Out-Null}
$script:ErrorFile = $script:ErrorFileDirectory + $(Get-Date -Format MMddyyyy_HHmm) + "_Errors.csv"
$script:RoboCopyReturnFile = $script:ErrorFileDirectory + $(Get-Date -Format MMddyyyy_HHmm) + "_RoboCopy.csv"
[String]$Source = (Read-Host -Prompt "Enter source share [e.g. \\29.222.253.230\Users1]").TrimEnd("\")
if ((Test-Path $Source) -eq $false) {
	throw "Source $Source does not exist."
}
if ($Source.Contains('$')) {
	throw "The use of administrative shares is not supported."
}
[String]$Destination = (Read-Host -Prompt "Enter destination share [e.g. \\29.222.253.230\Users4]").TrimEnd("\")
if ($Destination[-1] -ne "\") {$Destination += "\"}
if ((Test-Path $Destination) -eq $false) {
	throw "Destination $Destination does not exist."
}
if ($Destination.Contains('$')) {
	throw "The use of administrative shares is not supported. Press any key to exit."
}
[String]$Users = Read-Host -Prompt "Enter users or wildcard searches seperated by commas"
$UsersArray = $Users.Split(",").Trim() # Calling Trim() directly after split doesn't work on v2.0. Needs v3.0 or later.
$SourceDirectoriesArray = New-Object System.Collections.ArrayList
foreach ($User in $UsersArray) {
	[void]$SourceDirectoriesArray.AddRange([System.IO.Directory]::GetDirectories($Source,$User))
}
Write-Host -Object "There are $($SourceDirectoriesArray.Count) folders to be migrated.
Press L to list directories. Press C to cancel. Press any other key to proceed."
if ($Host.Name -match "Console") {
	$EnteredKey = [System.Console]::ReadKey($true)
	switch ($EnteredKey.Key) {
		L {
			Write-Output $SourceDirectoriesArray
			Write-Host "Continue? [y/n]"
			$Continue = [System.Console]::ReadKey($true)
			if ($Continue.Key -ne 'Y') {exit}
		}
		C {
			exit
		}
		default {
			continue
		}
	}
}
else {
	$EnteredKey = $Host.UI.ReadLine()
	switch ($EnteredKey) {
		L {
			Write-Output $SourceDirectoriesArray
			Write-Host "Continue? [y/n]"
			$Continue = $Host.UI.ReadLine()
			if ($Continue -ne 'Y') {exit}
		}
		C {
			exit
		}
		default {
			continue
		}
	}
}
$messagetitle = "Select migration phase"
$message = "Initial or Final?"

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Initial", `
"Only creates destination directories, assigns permissions, and performs robocopy"

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&Final", `
"Performs final move of U:\ drive"

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice($messagetitle, $message, $options, 0)
switch ($result) {
	0 { # Yes selected
		InitialPhase -SourceDirectoriesArray $SourceDirectoriesArray -Destination $Destination
	}
	1 { # No selected
		FinalPhase -SourceDirectoriesArray $SourceDirectoriesArray -Destination $Destination
	}
}
if ($script:ErrorCount -gt 0) {Write-Warning -Message "A total of $script:ErrorCount errors occurred during execution. Please read $script:ErrorFile"}
else {Write-Host -ForegroundColor 'Green' -Object "No errors occurred"}

<#
Remove-Variable TargetInfo
$SourceDirectoryACL = New-Object System.Security.AccessControl.DirectorySecurity -ArgumentList $SourceDirectory,"Access"
$SourceDirectoryPermissions = $SourceDirectoryACL.GetAccessRules($true, $false, [System.Security.Principal.NTAccount]) | Where-Object {$_.IdentityReference -notlike "DomainName\a-" -and $_.IdentityReference -ne "DomainName\svProvisioning"}
if ($SourceDirectoryPermissions.Count -eq 1) {
	$DFSUser = $SourceDirectoryPermissions[0].IdentityReference.ToString().Split("\")[-1]
	$TargetInfo = [NetApi32]::GetDFSLinkInfo("\\186.189.182.154\share\logs")
		if ($TargetInfo.Count -eq 1) { # The count of the returned C# ArrayList will be one and...
			if ($TargetInfo[0] -eq 1168) { # The value will be an Int32 if there was an error returned.
				# Unable to get DFS link via folder name or via SID permissions
				return
			}
			else {
				$TargetInfo = $TargetInfo[0]
			}
		}
		else {
			# More than one DFS link target. Found via SID/permissions.
		}
	}
#>