# Purpose: AnalyzeApplicationLog — General-purpose PowerShell utilities.
Get-EventLog �logname application |
Sort-Object �property source |
Group-Object �property source |
Sort-Object -Property count -Descending
