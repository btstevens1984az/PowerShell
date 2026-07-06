# Purpose: getcomputersPSCX — Windows desktop configuration and management.
if (-not (Get-PSSnapin PSCX -ErrorAction SilentlyContinue)) 
{
	Add-PSSnapin PSCX -ErrorAction stop
}
$computers =Get-ADObject -Domain nwtraders.com -PageSize 1000 -class computer | %{$_.name}
$computers