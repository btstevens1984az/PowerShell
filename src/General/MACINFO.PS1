# Purpose: MACINFO — General-purpose PowerShell utilities.
# powershell2 - quest active roles management shell for AD
# kerry kreitinger 
# get list of macs and computer names - export to list
#  plan to format MAC name list so it can be used to run WOL
#  filter out servers - -ComputerRole member -SizeLimit 0 -OSName 'Windows XP*', 'Windows 2000 Professional', 'Windows 7*', 'Windows Vista*'
#  list OS adn count  -SizeLimit 0 | group operatingsystem | sort Count -Descending


$COMPUTERLIST=GET-QADCOMPUTER

FOREACH ($PC IN $COMPUTERLIST) 
{ 

Get-WmiObject WIN32_NETWORKADAPTER -computer $PC.NAME | where { $_.PhysicalAdapter.CompareTo($FALSE) } | Format-table @{Label="ComputerName"; Expression={$PC.NAME}}, NAME, MACADDRESS

}



# to export replace format table
#  Get-WmiObject WIN32_NETWORKADAPTER -computer $PC.NAME | where { $_.PhysicalAdapter.CompareTo($FALSE) } | select-object NAME, MACADDRESS, @{Label="ComputerName"; Expression={$PC.NAME}} | Export-csv C:\MACADDRS.CSV

