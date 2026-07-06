# Purpose: TestGroupMembershipRecurse — General-purpose PowerShell utilities.
$user = Get-ADuser –Identity “TestDel88” –Property “memberof”
$group = Get-ADGroup –Identity “administrators”
$group2 = Get-ADGroup –Identity “DomainJoinGroup”
if (Get-ADUser -Filter { -not (memberOf -RecursiveMatch $group.DistinguishedName) -and  -not (memberOf -RecursiveMatch $group2.DistinguishedName)   } `
-SearchBase $user.DistinguishedName -SearchScope Base)
{$true}
Else
{$false}
