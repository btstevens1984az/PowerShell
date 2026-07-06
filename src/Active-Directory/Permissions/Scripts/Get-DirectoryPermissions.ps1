# Purpose: Get-DirectoryPermissions — Active Directory user, group, and domain administration.
<#	
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2014 v4.1.75
	 Created on:   	01/20/2018
	 Filename:     	Get-DirectoryPermissions.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>
[CmdletBinding()]
param (
	[Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
	[String[]]$Paths
)

BEGIN {
	$Results = New-Object System.Collections.ArrayList
	$Date = Get-Date -Format MMddyyyy_HHmmss
}

PROCESS {
	foreach ($Path in $Paths) {
		$Directory = [System.IO.DirectoryInfo]$Path
		$ParentACL = $Directory.GetAccessControl('Access').Access
		foreach ($ACL in $ParentACL) {
			$ParentInfo = New-Object PSObject -Property @{
				Path = $Directory.FullName
				FileSystemRights = $ACL.FileSystemRights
				AccessControlType = $ACL.AccessControlType
				IdentityReference = $ACL.IdentityReference
				IsInherited = $ACL.IsInherited
				InheritanceFlags = $ACL.InheritanceFlags
				PropagationFlags = $ACL.PropagationFlags
			}
			$Results.Add($ParentInfo)
		}
		
		$Subfolders = $Directory.GetDirectories()
		foreach ($Subfolder in $Subfolders) {
			$ChildACL = $Subfolder.GetAccessControl('Access').Access
			foreach ($ACL in $ChildACL) {
				$ChildInfo = New-Object PSObject -Property @{
					Path = $Subfolder.FullName
					FileSystemRights = $ACL.FileSystemRights
					AccessControlType = $ACL.AccessControlType
					IdentityReference = $ACL.IdentityReference
					IsInherited = $ACL.IsInherited
					InheritanceFlags = $ACL.InheritanceFlags
					PropagationFlags = $ACL.PropagationFlags
				}
				$Results.Add($ChildInfo)
			}
			$ChildSubfolders = $Subfolder.GetDirectories()
			foreach ($ChildSubfolder in $ChildSubfolders) {
				$ChildACL = $ChildSubfolder.GetAccessControl('Access').Access
				foreach ($ACL in $ChildACL) {
					$ChildInfo = New-Object PSObject -Property @{
						Path = $ChildSubfolder.FullName
						FileSystemRights = $ACL.FileSystemRights
						AccessControlType = $ACL.AccessControlType
						IdentityReference = $ACL.IdentityReference
						IsInherited = $ACL.IsInherited
						InheritanceFlags = $ACL.InheritanceFlags
						PropagationFlags = $ACL.PropagationFlags
					}
					$Results.Add($ChildInfo)
				}
			}
		}
	}
}

END {
	$Results | Select-Object Path, FileSystemRights, AccessControlType, IdentityReference, IsInherited, InheritanceFlags, PropagationFlags | Export-Csv -Path "$env:USERPROFILE\Desktop\Access_$Date.csv" -NoTypeInformation
}
