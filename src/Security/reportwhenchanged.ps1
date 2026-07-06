# Purpose: reportwhenchanged — Security auditing and compliance checks.
#JD
#This script demonstrates using the PSCX Active Directory Provider
#Advanced use of Format-table
#Type Casting
#use of -raw to get "real" AD properties using PSCX

if (-not (Get-PSSnapin PSCX -ErrorAction SilentlyContinue)) 
{
	Add-PSSnapin PSCX -ErrorAction stop
}

cd nwtraders:\
dir -rec | ?{$_.type -match "user"}| %{Get-ItemProperty $_ -raw} | FT -prop @{l="Name"; e={$_.SamAccountName}} `
	,@{l="Days Since Last Change";e={[int](((get-date)-($_.whenChanged)).totaldays)}}
