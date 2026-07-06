# Purpose: zzzIPandMAC — General-purpose PowerShell utilities.
clear-Host
get-WmiObject -class Win32_NetworkAdapterConfiguration -filter where-Object {$_.IPEnabled -eq 'True'} | '
format-Table IPAddress, MACAddress | '
export-csv c:\micomputerinfo.csv