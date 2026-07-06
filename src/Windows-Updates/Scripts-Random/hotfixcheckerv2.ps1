# Purpose: hotfixcheckerv2 — Windows Update and patch management.

$hotfixID = "KB944043-v3"
trap
{
$errortext = @"
Unable to load Quest Active Roles Powershell cmdlets. Please make sure they are installed.
The cmdlets can be downloaded from http://www.quest.com/powershell/activeroles-server.aspx
"@
Write-Host $errortext
exit

}

if (-not (Get-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction SilentlyContinue)) 
{
	Write-Host "Attempting to load Quest Active Roles cmdlets..."
	Add-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction stop
	Write-Host "Quest Active Roles cmdlets loaded successfully."
}

$servers = Get-QADComputer -OSName "Windows XP Professional" -PageSize 1000 -SizeLimit 0  -SearchRoot "cn=computers,dc=kaylos,dc=lab"| %{$_.name}
#$servers = Get-Content  "c:\temp\servers.txt"

foreach ($server in $servers)
{
	trap{ Write-host "WMI Error" ; continue}
	$result = gwmi Win32_quickfixengineering -comp $server -Filter "hotfixid='$hotfixid'"
	
	if ($result)
	{
		#Write-host "hotfix is installed"
		$server >> c:\temp\patched.txt
		
	}
	elseif($error)
	{ $server >> c:\temp\connectionerror.txt}
	else
	{
		#Write-host "hotfix is not installed"
		$server >> c:\temp\notpatched.txt
	}
	
	$error.clear()
}