# Purpose: ListCmdletsWithMoreThanOneAlias — General-purpose PowerShell utilities.
#
# ListCmdletsWithMoreThanOneAlias.ps1
# ed wilson, msft, 11/27/2008
#

Get-Alias | 
Group-Object -Property definition | 
Sort-Object -Property count -Descending | 
Where-Object { $_.count -gt 2 }