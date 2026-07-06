# Purpose: Add-LocalAdminGroupMember — Active Directory user, group, and domain administration.

$Servers = "29.222.253.230", "ServerHostname", "ServerHostname"
$Users = "Active Directory Group"

foreach ($Server in $Servers) {
	$Group = [ADSI]("WinNT://$Server/Administrators,group")
	foreach ($User in $Users) {
		try {
			$Group.Add("WinNT://example.com/$User")
		}
		catch {
			Write-Output $Server,$User,$($_.Exception.Message.Replace("`n",""))
		}
	}
}