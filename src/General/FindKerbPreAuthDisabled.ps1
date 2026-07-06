# Purpose: FindKerbPreAuthDisabled — General-purpose PowerShell utilities.
#Find Users which are configured to not require Kerberos Pre-Authentication
$users = Get-ADUser -Filter {UserAccountControl -band 0x400000} -Properties useraccountcontrol
$users
#$users[0].useraccountcontrol -bxor 0x400000