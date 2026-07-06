# Purpose: DumpGroupPerm — General-purpose PowerShell utilities.
Import-Module ActiveDirectory
# Get-ADGroup -Identity "domain admins"
$groups = get-adgroup -Filter *
$domain = Get-ADDomain
cd AD:
cd $domain.DistinguishedName
#$groupAcls = $groups.DistinguishedName |  %{get-acl -PSPath "AD:/$_"}
$groupAcls = $groups | %{$_.DistinguishedName}| %{get-acl -PSPath "AD:/$_"}
$groupAcls | Export-Clixml c:\temp\groupPerms.xml