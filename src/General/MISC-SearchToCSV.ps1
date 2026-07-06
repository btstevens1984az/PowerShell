# Purpose: MISC-SearchToCSV — General-purpose PowerShell utilities.
#   James Wylde

#----------------------------------------------------------------------------------------#
#   Modules

$var = Read-Host = "Search term"

Get-ChildItem -Path C:\ -Include $var -File -Recurse -ErrorAction SilentlyContinue | Export-CSV -Path C:\Temp\export.csv

#$results = Get-ChildItem -Path C:\ -Include $var -File -Recurse -ErrorAction SilentlyContinue | Export-CSV -Path C:\Temp\export.csv

Write-Host = "`r`n"

Write-Host = "Results are located C:\Temp\export.csv" -ForegroundColor Red -BackgroundColor Green


#----------------------------------------------------------------------------------------#
#   Remote

Clear-Host

$hostname = Read-Host - "Hostname"
 
Invoke-Command -ComputerName $hostName -ScriptBlock {
 
$var = Read-Host = "Search"
 
Get-ChildItem -Path C:\temp -Include $var -File -Recurse -ErrorAction SilentlyContinue}
 
Get-ChildItem -Path C:\temp -Include $var -File -Recurse -ErrorAction SilentlyContinue | Export-CSV -Path C:\Temp\export.csv | Out-File -FilePath C:\Temp\export.txt
 
#Get-ChildItem -Path C:\ -Include $var -File -Recurse -ErrorAction SilentlyContinue | Out-File -FilePath C:\Temp\export.txt
 
Write-Host = "`r`n"
 
Write-Host = "Results are located C:\Temp\export.csv" -ForegroundColor Black -BackgroundColor White