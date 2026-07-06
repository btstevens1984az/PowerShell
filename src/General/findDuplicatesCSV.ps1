# Purpose: findDuplicatesCSV — General-purpose PowerShell utilities.
$csv = Import-Csv C:\temp\temp.csv
$duplicates =$csv | Group-Object firstname,lastname | where-object{$_.count -gt 1}
$duplicates | ForEach-Object{$_.group} | Export-Csv c:\temp\duplicates.csv -NoTypeInformation