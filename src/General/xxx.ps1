# Purpose: xxx — General-purpose PowerShell utilities.
$COMPUTERLIST=GET-QADCOMPUTER

FOREACH ($PC IN $COMPUTERLIST) 
{ 

Get-WmiObject WIN32_NETWORKADAPTER -computer $PC.NAME | where { $_.PhysicalAdapter.CompareTo($FALSE) } | Format-table @{Label="ComputerName"; Expression={$PC.NAME}}, NAME, MACADDRESS, 

}
| out-file c:\admintasks\wols.txt