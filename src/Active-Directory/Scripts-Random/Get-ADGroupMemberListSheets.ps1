# Purpose: Get-ADGroupMemberListSheets — Active Directory user, group, and domain administration.
# Filename:      Get-ADGroupMemberList.ps1

$GroupList = Get-Content "C:\tmp\HPCAADgroups.txt"
write-host The following AD Groups are in the list
write-host $groupList

ForEach ($groupName in $GroupList)
{


$currentGroup = $groupname
write-host -foregroundcolor yellow $currentGroup is processing now
   Get-ADGroupMember -identity "$CurrentGroup" -recursive | select name | Export-csv -path C:\Temp\HPCAGroups\$CurrentGroup.csv -NoTypeInformation
   
   }