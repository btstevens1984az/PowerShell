# Purpose: ListServerShares — General-purpose PowerShell utilities.
########################################################
# ListShares.ps1
# ed wilson, msft, 6/12/2007
#
# uses get-wmiobject cmdlet and win32_share class to
# list information about shares. 
#
########################################################

$serverlist = "c:\admintasks\servers.txt"

Get-WmiObject -Class win32_share -ComputerName $serverlist | 
Sort-Object name | 
Format-Table name, path, description -AutoSize | out-file c:\powershellreports\serverShares.csv