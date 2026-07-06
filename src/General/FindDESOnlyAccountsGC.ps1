# Purpose: FindDESOnlyAccountsGC — General-purpose PowerShell utilities.
Get-ADUser –filter {UserAccountControl -band 0x200000} -server "dc2:3268" 