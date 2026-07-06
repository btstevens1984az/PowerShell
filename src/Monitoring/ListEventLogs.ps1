# Purpose: ListEventLogs — System monitoring and alerting.
# ListEventLogs.ps1

Get-Event -ListLog * | 
Format-Table -Property logname, RecordCount -AutoSize