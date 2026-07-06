# Purpose: Add-LocalAdminGroupMember — General-purpose PowerShell utilities.

$Servers = "114.148.18.125", "119.223.48.126", "134.127.11.250"
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