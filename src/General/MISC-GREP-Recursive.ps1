# Purpose: MISC-GREP Recursive — General-purpose PowerShell utilities.
#   James Wylde 2020

#----------------------------------------------------------------------------------------#
#   Modules

Get-ChildItem c:\ -Recurse | Select-String -Pattern hstbar.xla | Export-csv -Path c:\Temp\ExportSearch.csv
 