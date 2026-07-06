# Purpose: getusersPSCX — General-purpose PowerShell utilities.
if (-not (Get-PSSnapin PSCX -ErrorAction SilentlyContinue)) 
{
	Add-PSSnapin PSCX -ErrorAction stop
}

$users =Get-ADObject -Domain nwtraders.com -PageSize 1000 -class user | %{$_.name}
$users