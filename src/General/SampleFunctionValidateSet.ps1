#$SITE = "MEMS"
#$SSP = "GUAMEM"
<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
Function Set-SiteDFSR
{
[CmdletBinding()]
param(  $SITE = "MEMS",
        $SSP = "GUAMEM",
        [Parameter(Mandatory=$true)]
        [ValidateSet("PAC", "EU", "AM")]
        [string]$Regions )

#File Server DFSR stuff
New-DfsReplicationGroup -GroupName "$SITE-FILE"
Set-DfsrGroupSchedule -GroupName "$SITE-FILE" -ScheduleType Never
Add-DfsrMember -GroupName "$SITE-FILE" -ComputerName "$SITE-FILE01","$Regions-$SSP-FS1"
Add-DfsrConnection -GroupName "$SITE-FILE" -SourceComputerName "$SITE-FILE01" -DestinationComputerName "$Regions-$SSP-FS1"

New-DfsReplicatedFolder -GroupName "$SITE-FILE" -FolderName "$SITE-NetApp"
Set-DfsrMembership -GroupName "$SITE-FILE" -FolderName "$SITE-NetApp" -ContentPath "F:\NetApp" -ComputerName "$SITE-FILE01" -PrimaryMember $True -StagingPathQuotaInMB 40960 -Force
Set-DfsrMembership -GroupName "$SITE-FILE" -FolderName "$SITE-NetApp" -ContentPath "G:\Shares\Common\$SITE-NetApp" -ComputerName "$Regions-$SSP-FS1" -StagingPathQuotaInMB 40960 -Force

New-DfsReplicatedFolder -GroupName "$SITE-FILE" -FolderName "$SITE-PAC"
Set-DfsrMembership -GroupName "$SITE-FILE" -FolderName "$SITE-PAC" -ContentPath "F:\PAC.Folder" -ComputerName "$SITE-FILE01" -PrimaryMember $True -StagingPathQuotaInMB 40960 -Force
Set-DfsrMembership -GroupName "$SITE-FILE" -FolderName "$SITE-PAC" -ContentPath "E:\Shares\Mission Critical\$SITE" -ComputerName "$Regions-$SSP-FS1" -StagingPathQuotaInMB 40960 -Force

New-DfsReplicatedFolder -GroupName "$SITE-FILE" -FolderName "$SITE-SITE"
Set-DfsrMembership -GroupName "$SITE-FILE" -FolderName "$SITE-SITE" -ContentPath "F:\SITE.Folder" -ComputerName "$SITE-FILE01" -PrimaryMember $True -StagingPathQuotaInMB 40960 -Force
Set-DfsrMembership -GroupName "$SITE-FILE" -FolderName "$SITE-SITE" -ContentPath "G:\Shares\Common\$SITE" -ComputerName "$Regions-$SSP-FS1" -StagingPathQuotaInMB 40960 -Force

New-DfsReplicatedFolder -GroupName "$SITE-FILE" -FolderName "$SITE-Staff"
Set-DfsrMembership -GroupName "$SITE-FILE" -FolderName "$SITE-Staff" -ContentPath "F:\User\Staff" -ComputerName "$SITE-FILE01" -PrimaryMember $True -StagingPathQuotaInMB 40960 -Force
Set-DfsrMembership -GroupName "$SITE-FILE" -FolderName "$SITE-Staff" -ContentPath "F:\Shares\Staff\$SITE" -ComputerName "$Regions-$SSP-FS1" -StagingPathQuotaInMB 40960 -Force

New-DfsReplicatedFolder -GroupName "$SITE-FILE" -FolderName "$SITE-Class"
Set-DfsrMembership -GroupName "$SITE-FILE" -FolderName "$SITE-Class" -ContentPath "G:\Class" -ComputerName "$SITE-FILE01" -PrimaryMember $True -StagingPathQuotaInMB 40960 -Force
Set-DfsrMembership -GroupName "$SITE-FILE" -FolderName "$SITE-Class" -ContentPath "G:\Shares\Common\$SITE-Class" -ComputerName "$Regions-$SSP-FS1" -StagingPathQuotaInMB 40960 -Force

New-DfsReplicatedFolder -GroupName "$SITE-FILE" -FolderName "$SITE-Collab"
Set-DfsrMembership -GroupName "$SITE-FILE" -FolderName "$SITE-Collab" -ContentPath "G:\Collaboration" -ComputerName "$SITE-FILE01" -PrimaryMember $True -StagingPathQuotaInMB 40960 -Force
Set-DfsrMembership -GroupName "$SITE-FILE" -FolderName "$SITE-Collab" -ContentPath "G:\Shares\Common\$SITE-Collaboration" -ComputerName "$Regions-$SSP-FS1" -StagingPathQuotaInMB 40960 -Force

Get-DfsrMembership -GroupName "$SITE-FILE" | FT -Property "GroupName", "FolderName", "ComputerName", "PrimaryMember"
}