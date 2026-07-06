# Purpose: srvs — General-purpose PowerShell utilities.
# get-qadcomputer -SerializeValues -IncludeAllProperties -sizelimit 0 | export-csv c:\admintasks\sv.cs



# get-qadcomputer -SerializeValues -sizelimit 0 | format-table -property CN, OperatingSystem, OperatingSytemVersion, OperatingSystemServicePack, whenCreated |export-csv c:\admintasks\serverInfo.csv

# Get-QADComputer -searchroot  'DC=example,DC=local' -OSName 'Windows*Server*' | export-csv c:\admintasks\svvvv.csv






Get-QADComputer -OSName 'Windows*Server*'| format-table -property computername, osname, osversion, osservicepack