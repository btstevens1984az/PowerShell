# Purpose: Last60days — General-purpose PowerShell utilities.
Get-QADUser -enabled -sizelimit 0 |`
Select-Object SamAccountName,@{n="LastLogonTimeStamp";e={$_.LastLogonTimeStamp.value}},WhenCreated,Description|`
Sort-Object LastLogonTimeStamp |`
Export-Csv c:\powershellreports\last60days2.csv