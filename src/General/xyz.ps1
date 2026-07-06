# Purpose: xyz — General-purpose PowerShell utilities.
$COMPUTERLIST=GET-QADCOMPUTER

FOREACH ($PC IN $COMPUTERLIST) 
{ 

Get-WmiObject WIN32_NETWORKADAPTER -computer $PC.NAME | where { $_.PhysicalAdapter.CompareTo($FALSE) } | select-object NAME, MACADDRESS, @{Label="ComputerName"; Expression={$PC.NAME}} | Export-csv C:\MACADDRS.CSV

} 
