# Purpose: ListClassicEventLogs — System monitoring and alerting.
# ListClassicEventLogs.ps1

Get-Event -ListLog * | 
Where-Object { $_.isClassicLog } | 
Format-Table -Property logname, MaximumSize*, *count -AutoSize