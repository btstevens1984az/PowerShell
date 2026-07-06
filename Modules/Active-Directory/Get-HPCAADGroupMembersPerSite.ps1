# Purpose: Get-HPCAADGroupMembersPerSite — Active Directory user, group, and domain administration.

Function Get-HPCAADGroupMembersPerSite {
$GroupList = Get-Content 'C:\Users\$env:USERNAME\Desktop\HPCA_Patach_ADGroups.txt'
write-host The following AD Groups are in the list
write-host $groupList

ForEach ($groupName in $GroupList)
{
$currentGroup = $groupname
write-host -foregroundcolor yellow $CurrentGroup is processing now
   Get-ADGroupMember -identity "$CurrentGroup" -recursive | select name | Export-csv -path C:\Users\$env:USERNAME\Desktop\WannaCry\$CurrentGroup.csv -NoTypeInformation 
   }
}