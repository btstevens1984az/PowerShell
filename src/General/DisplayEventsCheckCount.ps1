# Purpose: DisplayEventsCheckCount — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 11/8/2008
#
# KEYWORDS: Get-Event, recordcount, select-object
# requires -version 2.0
# COMMENTS: This script checks the number of event
# records before attempting to retrieve the events via the
# get-event cmdlet. This will trap the error that would 
# arise otherwise. 
#
# ------------------------------------------------------------------------

#requires -version 2.0
$logname = "*bits*op*"
$numberLogs = 3
if((Get-Event -ListLog $logname).recordCount)
{
 "Displaying the last $numberLogs events from log $logName"
 Get-Event -LogName $logname |
 Select-Object -last $numberLogs
}