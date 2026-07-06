# Purpose: FormatWHash — PowerShell automation.
#JD
Get-Process | FT name,@{l="workingsetSize";e={([string]($_.WS/1MB))+"MB"}} -auto
#Get-Process | FT name,@{label="workingsetSize";expression={([string]($_.WS/1MB))+"MB"}} -auto