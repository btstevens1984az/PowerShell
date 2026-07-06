# Purpose: adsiDemo1 — General-purpose PowerShell utilities.
$ADsPath = "LDAP://CN=Administrator,CN=Users," + ([ADSI]"").distinguishedName
$user1 = [ADSI]$ADsPath
$user1 | get-member
$user2 = $user1.psbase
$user2 | get-member
