# Purpose: GetErrorsFromAllLogFiles — Storage management and disk operations.
#uses the Get-EventLog cmdlet to retrieve all error messages from
#the last 200 events written to the application, system, and security log
clear-host
$aryLogs = 'application', 'system','security'
foreach($strLog in $aryLogs)
{
Write-Host "The following are errors from the $strLog log file"
Get-EventLog -LogName $strLog -Newest 200 | 
Where-Object { $_.entryType -eq "Error" } | 
format-list time, source, eventID, message, data
}