# Purpose: hotfixchecker — Windows Update and patch management.
#JD
#Script that reads a file of servers names and checks them for a specific hotfix id.
#demonstrates using trap to prevent terminatings errors from stopping the script
$hotfixID = "kb958687"
$servers = Get-Content  "c:\temp\servers.txt"

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