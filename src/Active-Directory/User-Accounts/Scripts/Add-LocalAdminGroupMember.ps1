# Purpose: Add-LocalAdminGroupMember — Active Directory user, group, and domain administration.

$Servers = "server hostname1", "server hostname 2", "server hostname 3"
$Users = "ExampleGroupName"

foreach ($Server in $Servers) {
	$Group = [ADSI]("WinNT://$Server/Administrators,group")
	foreach ($User in $Users) {
		try {
			$Group.Add("WinNT://YOURDOMAIN/$User")
		}
		catch {
			Write-Output $Server,$User,$($_.Exception.Message.Replace("`n",""))
		}
	}
}
