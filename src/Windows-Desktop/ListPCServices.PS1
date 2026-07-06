# Purpose: ListPCServices — Windows desktop configuration and management.
# PowerShell2
# Kerry K
# get list of  Servers - query each server for services and write to CSV
# Get-QADComputer -SearchRoot -OSName ''| where OSNAME -ne '*SERVER*' | select name | out-file H:\AD-Reports\PCs.txt
# where { $_.osname -ne '*SERVER*'} 
# $ServerList= Get-QADComputer -OSName '*SERVER*'
#  | select name | out-file H:\AD-Reports\ADServers.txt
# $ServerList= get-content H:\AD-Reports\ADServers.txt
# - line to all pcs - get-qadcomputer -OSName '*'| where { $_.OSName -ne '*SERVER*'} | select name
# $CSVPath= "H:\AD-Reports\ServerServices.csv"
#foreach ($YS in $ServerList)
# { 
# Get-WmiObject -Class win32_service -ComputerName $YS.name | select DisplayName,Name,StartName,State,StartMode,SystemName,Status,PathName
#
# }
# export-csv h:\ad-reports\services.csv

# ListPCServices.PS1
# source list is defined by path for $ServerList variable
# path to write file is $CSVPath
# $YS is the computer name read from the source list - a array is needed here to get info from each computer
# extra variabls must be defined when passing results inside a script

# $job = test-connection -destination (get-content H:\AD-Reports\ADC-computers.txt) -asjob

# if ($job.jobstateinfo.state -ne "Running") {$results = receive-job $job}

# add code to ping system then only run against systems which respond - combine cmds below and pipe list of machines to it
# Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE |
# Select-Object -ExpandProperty DNSServerSearchOrder |
# ForEach-Object -Process {Get-WmiObject -Class Win32_PingStatus -Filter ("Address='" + $_ + "'")} |
#  Select-Object -Property Address,ResponseTime
get-qadcomputer -SizeLimit 0 | where {$_.osname -notlike '*server*'}| select name | out-file H:\AD-Reports\ADC-computers.txt -force
get-content H:\AD-Reports\adc-computers.txt |ForEach-Object {test-connection -destination $_}
# $job = test-connection -destination (get-content H:\AD-Reports\ADC-computers.txt) -asjobif ($job.jobstateinfo.state -ne "Running") {$results = receive-job $job}
# if ($job.jobstateinfo.state -ne "Running") {$results = receive-job $job}

# get-qadcomputer -sizelimit 0 -ldap '(!operatingSystem=*server*)' | select name | out-file H:\AD-Reports\ADC-computers.txt -force
get-content H:\AD-Reports\adc-computers.txt |ForEach-Object {gwmi win32_service -computerName $_}| select DisplayName,Name,StartName,State,StartMode,SystemName,Status,PathName | export-csv h:\ad-reports\PCServicesTEST.csv


test-connection -destination (get-content H:\AD-Reports\ADC-computers.txt) | select address,statuscode,ipv4address