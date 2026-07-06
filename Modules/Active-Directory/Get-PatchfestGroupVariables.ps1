# Purpose: Get-PatchfestGroupVariables — Active Directory user, group, and domain administration.
Function Get-PatchFestReportVariables {
#cd $env:windir
#Install-Module -Name ActiveDirectory -Force
#Import-Module -Name ActiveDirectory -Force
$Group1001 = Get-ADGroupMember "PatchFest - Group 1001 Servers" | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
$Group1002 = Get-ADGroupMember "PatchFest - Group 1002 Servers" | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
$Group1003 = Get-ADGroupMember "PatchFest - Group 1003 Servers" | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
$Group1004 = Get-ADGroupMember "PatchFest - Group 1004 Servers" | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
$Group4 = Get-ADGroupMember "PatchFest - Group 4 Servers" | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
$Group5 = Get-ADGroupMember "PatchFest - Group 5 Servers" | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
$Group6 = Get-ADGroupMember "PatchFest - Group 6 Servers" | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
$Group8 = Get-ADGroupMember "PatchFest - Group 8 Servers" | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
$Group10 = Get-ADGroupMember "PatchFest - Group 10 Servers" | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
$GroupTestServers = Get-ADGroupMember "PatchFest - Test Servers" | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
$GroupExcludedServers = Get-ADGroupMember "PatchFest - Excluded Servers" | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
$GroupDecommissionedServers = Get-ADGroupMember "PatchFest - Decommissioned Servers" | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
$GroupDTeamServers = Get-ADGroupMember "PatchFest - Automation Team Servers" | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($Group1001).count
($Group1002).count
($Group1003).count
($Group1004).count
($Group4).count
($Group5).count
($Group6).count
($Group8).count
($Group10).count
($GroupTestServers).count
($GroupExcludedServers).count
($GroupDecommissionedServers).count
($GroupTeamServers).count
}