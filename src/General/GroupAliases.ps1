# Purpose: GroupAliases — General-purpose PowerShell utilities.
Get-Alias | 
Group-Object �property definition | 
Sort-Object -Property count -Descending
