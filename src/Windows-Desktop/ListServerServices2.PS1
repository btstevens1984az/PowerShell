# Purpose: ListServerServices2 — Windows desktop configuration and management.
# PowerShell2 -  logic is wrong - incorrect wmi query
# Kerry K
# get list of  Servers - query each server for services and write to CSV

# Get-QADcomputer | where {$_.obj.class -eq �Server�} | select name| out-file H:\AD-Reports\ADServers.txt
# Get-QADComputer -SearchRoot -OSName '*SERVER*'
$ServerList= Get-QADComputer -OSName '*SERVER*'
#  | select name | out-file H:\AD-Reports\ADServers.txt
# $ServerList= get-content H:\AD-Reports\ADServers.txt

$CSVPath= "H:\AD-Reports\ADServerServices2.csv"
foreach ($YS in $ServerList)
# { 
# Get-WmiObject -Class win32_service -ComputerName $YS.name | select DisplayName,Name,StartName,State,StartMode,SystemName,Status,PathName  | export-csv $CSVPath

# }

# ListServerServices2.PS1
# source list is defined by path for $ServerList variable
# path to write file is $CSVPath
# $YS is the computer name read from the source list - a array is needed here to get info from each computer
# extra variabls must be defined when passing results inside a script

# add code to ping system then only run against systems which respond - combine cmds below and pipe list of machines to it
# Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE |
# Select-Object -ExpandProperty DNSServerSearchOrder |
# ForEach-Object -Process {Get-WmiObject -Class Win32_PingStatus -Filter ("Address='" + $_ + "'")} |
#  Select-Object -Property Address,ResponseTime

get-wmiobject -Class Win32_Service -ComputerName $YS | foreach-object { $_.name() } | select DisplayName,Name,StartName,State,StartMode,SystemName,Status,PathName  | export-csv $CSVPath
