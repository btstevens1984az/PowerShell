# Purpose: GetDistroGroups2CSV — General-purpose PowerShell utilities.
# PowerShell2
# Kerry k
# get list of distribution groups - save to csv
# use list to create csvs for membership

connect-qadservice -service '14.33.184.29'

$strGroupPath = "H:\AD-Reports\DistributionGroups.csv"
$dom = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$root = $dom.GetDirectoryEntry()
$search = [System.DirectoryServices.DirectorySearcher]$root


# $search.Filter = "(objectClass=GROUP)"
# $searcher.filter = "(&(&(&(&(objectClass=group)(!(objectClass=computer))(ou:dn:=Distribution Group)))))"
# get-QADGroup -SearchRoot 'company.com/GroupsOU' -GroupType 'Distribution' -sizelimit 0

get-QADGroup -SearchRoot '14.33.184.29/Distribution Group' -GroupType 'Distribution' -sizelimit 0 | Select-Object DN, Name, email | Export-Csv -Path $strGroupPath
 
$Stuff = Import-CSV $strGroupPath 
ForEach ($DistroGroup in $Stuff){
$groupName = $DistroGroup.name
Get-QADGroupMember -identity $groupName | Select-Object LogonName, DisplayName, AccountIsDisabled, AccountIsExpired, Email,PhoneNumber | Export-Csv -Path "H:\AD-Reports\$groupName.csv"
}
