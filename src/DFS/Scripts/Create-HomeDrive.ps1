# Purpose: Create-HomeDrive — PowerShell automation.
param($NoExit)

# restart PowerShell with -noexit, the same script, and 1
if (!$NoExit) {
	$Host.UI.RawUI.BackgroundColor = "Black"
	Clear-Host
    powershell -noexit -file $MyInvocation.MyCommand.Path 1
    return
}
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
$DFSServer = "ServerHostname"
$HomeDriveServerFile = "\\197.222.226.174\Home and Group Folders\CurrentHomeDriveServers.txt"
$FolderRedirectionGroup = "AD Cluster Group Name"
try {
	Import-Module ActiveDirectory -ErrorAction 'Stop'
}
catch {
	throw "There was an error importing the Active Directory module.`n$_.Exception.Message"
}

$EnteredUsername = Read-Host -Prompt "Enter username"
try {
	$EnteredUserObj = Get-ADUser -Identity $EnteredUsername -Properties HomeDirectory,HomeDrive,MemberOf -ErrorAction 'Stop'
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
	throw "A user with username, $EnteredUsername, was not found"
}
catch [System.Management.Automation.ParameterBindingException] {
	throw "No username was entered. Please enter a username"
}
catch {
	throw "Error getting user information. The error was:`n$_.Exception.Message"
}
if ($EnteredUserObj.HomeDirectory -ne $null) { # Something exists in the user's HomeDirectory attribute
	$HomeDirectory = $EnteredUserObj.HomeDirectory
	$HomeDrive = $EnteredUserObj.HomeDrive
	Write-Warning -Message "User $($EnteredUserObj.SamAccountName) already has something in their HomeDirectory attribute.`nHomeDirectory = $HomeDirectory`nHomeDrive = $HomeDrive"
	if ($EnteredUserObj.HomeDirectory -notmatch $DFSServer) { # If what's in their attribute already doesn't have "ServerHostname" in it
		throw "$($EnteredUserObj.SamAccountName) HomeDirectory attribute is not $DFSServer.`nSuspect user has WR or AK H:\ drive.`nStopping script"
	}
}
else { # Otherwise, set variables for verification and/or creation
	Write-Host -ForegroundColor 'Green' -Object "HomeDirectory attribute for $($EnteredUserObj.SamAccountName) is not currently set"
	$HomeDirectory = "\\186.189.182.154\share\logs"
	$HomeDrive = "H:"
}
Write-Host -ForegroundColor 'Cyan' -Object "Checking whether a DFS link exists for $($EnteredUserObj.SamAccountName)"
$CurrentDFSLink = [NetApi32]::GetDFSLinkInfo($HomeDirectory) # Check for DFS link regardless of whether HomeDirectory is set or not
if ($CurrentDFSLink.Count -eq 1) { # The count of the returned C# ArrayList will be one and...
	if ($CurrentDFSLink[0] -is [Int32]) { # The value will be an Int32 if there was an error returned.
		switch ($CurrentDFSLink[0]) {
			1168 {
				# 1168 is ERROR_NOT_FOUND. Element not found.
				# 5 is ERROR_ACCESS_DENIED. Access is denied.
				Write-Host -ForegroundColor 'Green' -Object "A DFS link doesn't already exist"
				continue
			}
			default {
				throw "An unknown error occurred while calling GetDFSLinkInfo. The error code was $($CurrentDFSLink[0])`nStopping script"
			}
		}
	}
	else { # If the count of the array list is 1 but the returned value isn't an integer (means there's an existing link with a target)
		$DFSTarget = "\\$($CurrentDFSLink[0].ServerName)\$($CurrentDFSLink[0].ShareName)"
		throw "A DFS link, $HomeDirectory, exists for user $($EnteredUserObj.SamAccountName)`nDFS Link Target:`n$($DFSTarget)`nStopping script"
	}
}
else { # Count of elements in the arraylist is not 1 (usually greater)
	# Means that more than one DFS link target exists
	$DFSTarget = [String]""
	for ($i=0; $i -lt $CurrentDFSLink.Count; $i++) {
		$DFSTarget += "\\$($CurrentDFSLink[$i].ServerName)\$($CurrentDFSLink[$i].ShareName)`n"
	}
	throw "A DFS link, $HomeDirectory, exists with more than one target for user $($EnteredUserObj.SamAccountName)`nDFS Link Targets`n$($DFSTarget)`nStopping script"
}

$messagetitle = "Select creation mode"
$message = "Run H:\ drive creation in Automatic mode?"

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
"Runs script in automatic mode."

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
"Runs script in manual mode."

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice($messagetitle, $message, $options, 0)
switch ($result) {
	0 { # Yes selected
		try {
			$HomeDriveLocations = [System.IO.File]::ReadAllLines($HomeDriveServerFile) | ForEach-Object {$_.Trim()} | Where-Object {[String]::IsNullOrEmpty($_) -eq $false}
#			$HomeDriveLocations = [System.IO.File]::ReadAllLines($HomeDriveServerFile) | Where-Object {[String]::IsNullOrWhiteSpace($_) -eq $false}
#			IsNullOrWhiteSpace requires PSv3 http://blog.danskingdom.com/powershell-2-0-vs-3-0-syntax-differences-and-more/
#			$HomeDriveLocations = $HomeDriveLocations.Trim()
#			Don't need seperate Trim method. Trimming as part of pipeline.
		}
		catch {
			Write-Error -Message "An error occurred while getting list of current H:\ drive servers. The error was:`n$($_.Exception.Message)"
			$HomeDriveLocations = Read-Host -Prompt "Please enter server and share to create H:\ drive on [e.g. \\240.217.252.191\user1]"
			$HomeDriveLocations = $HomeDriveLocations.Trim()
		}
	}
	1 { # No selected
		$HomeDriveLocations = Read-Host -Prompt "Please enter server and share to create H:\ drive on [e.g. \\240.217.252.191\user1]"
		$HomeDriveLocations = $HomeDriveLocations.Trim()
	}
}
if ($HomeDriveLocations -is [Array]) {
	for ($i=0; $i -lt $HomeDriveLocations.Count; $i++) {
		if ($HomeDriveLocations[$i][-1] -ne "\") {$HomeDriveLocations[$i] = $HomeDriveLocations[$i] + "\"}
	}
}
else {
	if ($HomeDriveLocations[-1] -ne "\") {$HomeDriveLocations = $HomeDriveLocations + "\"}
}
$ChosenHDriveLocation = Get-Random -InputObject $HomeDriveLocations
Write-Host -ForegroundColor 'Cyan' -Object "Attempting to create H:\ drive for $($EnteredUserObj.SamAccountName) on $ChosenHDriveLocation"
$Rights = New-Object System.Security.AccessControl.FileSystemAccessRule -ArgumentList $($EnteredUserObj.SID),Modify,3,None,Allow
try {
	$ParentDirectory = [System.IO.Directory]::GetParent($ChosenHDriveLocation)
	if ([System.IO.Directory]::Exists("$($ParentDirectory.FullName)\$($EnteredUserObj.SamAccountName)")) {
		Write-Warning -Message "Directory $($ParentDirectory.FullName)\$($EnteredUserObj.SamAccountName) exists prior to its creation!" -WarningAction 'Inquire'
	}
	$SubDirectory = $ParentDirectory.CreateSubdirectory($($EnteredUserObj.SamAccountName))
	Write-Host -ForegroundColor 'Green' -Object "Successfully created folder $($Subdirectory.FullName)"
	$SubDirectoryACL = $SubDirectory.GetAccessControl()
	$SubDirectoryACL.AddAccessRule($Rights)
	$SubDirectory.SetAccessControl($SubDirectoryACL)
	Write-Host -ForegroundColor 'Green' -Object "Successfully granted $($EnteredUserObj.SamAccountName) rights to folder $($Subdirectory.FullName)"
	}
catch {
	throw "Error during creation or ACL of subdirectory on $ChosenHDriveLocation. The error was:`n$($_.Exception.Message)`nStopping script"
}
[URI]$Target = $SubDirectory.FullName
$CreateDFSReturn = [NetApi32]::NetDfsAdd($HomeDirectory,$Target.Host,$Target.AbsolutePath.TrimStart("/").Replace("/","\"),$null,0)
if ($CreateDFSReturn -ne 0) {throw "Error creating DFS link. Error code returned was $($CreateDFSReturn)"}
else {Write-Host -ForegroundColor 'Green' -Object "Successfully created DFS link $HomeDirectory with target $($Target.LocalPath)"}
try {
	Set-ADUser -Identity $EnteredUserObj -HomeDrive $HomeDrive -HomeDirectory $HomeDirectory -ErrorAction 'Stop'
}
catch {
	throw "Error while setting HomeDrive and HomeDirectory attributes for $($EnteredUserObj.SamAccountName). The error was:`n$($_.Exception.Message)`nStopping script"
}
Write-Host -ForegroundColor 'Green' -Object "Successfully set HomeDirectory and HomeDrive attributes for $($EnteredUserObj.SamAccountName)"
$FolderRedirectionGroupObj = Get-ADGroup -Identity $FolderRedirectionGroup
if ($EnteredUserObj.MemberOf -notcontains $FolderRedirectionGroupObj.DistinguishedName) {
	try {
		Add-ADPrincipalGroupMembership -Identity $EnteredUserObj -MemberOf $FolderRedirectionGroupObj -ErrorAction 'Stop'
	}
	catch {
		Write-Error -Message "Error adding user to $($FolderRedirectionGroupObj.SamAccountName). Error was $($_.Exception.Message)"
		continue
	}
	Write-Host -ForegroundColor 'Green' -Object "Successfully added $($EnteredUserObj.SamAccountName) to $($FolderRedirectionGroupObj.SamAccountName)"
}
else {
	Write-Host -ForegroundColor 'Cyan' -Object "User $($EnteredUserObj.SamAccountName) already member of $($FolderRedirectionGroupObj.SamAccountName)"
}
Write-Host -ForegroundColor 'Cyan' -Object "H:\ drive creation complete"