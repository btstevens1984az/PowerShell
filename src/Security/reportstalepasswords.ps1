# Purpose: reportstalepasswords — Security auditing and compliance checks.
#JD
#problem with incorrect date conversion of pwdlastset
#This script demonstrates using the PSCX Active Directory Provider
#Add-pssnapin PSCX
cd nwtraders:
dir -rec | ?{$_.type -match "user"}| %{Get-ItemProperty $_} | FT -prop @{l="Name"; e={$_.SamAccountName}} `
	,@{l="PasswordAge";e={[int](((get-date)-($_.passwordlastset)).totaldays)}}