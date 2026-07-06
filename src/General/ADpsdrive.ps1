# Purpose: ADpsdrive — General-purpose PowerShell utilities.
# cd domainname:
#uses PSCX from http://www.codeplex.com/PowerShellCX
#returns usernames and password last changed date
dir -rec | ?{$_.type -match "user"}| %{Get-ItemProperty $_ | FT SamAccountName,passwordlastset}