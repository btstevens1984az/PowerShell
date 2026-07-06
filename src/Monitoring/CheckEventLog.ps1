# Purpose: CheckEventLog — System monitoring and alerting.
# ------------------------------------------------------------------------
# DATE: 4/4/2009
#
# KEYWORDS: Get-EventLog, Param, Function
#
# COMMENTS: This accepts two parameters the logname
# and the number of events to retrieve. If no number for
# -max is supplied it retrieves the most recent entry. 
# The script fails if the security log is targeted and it is
# not run with admin rights.
# TODO: Add function to check for admin rights if
# the security log is targeted. 
# ------------------------------------------------------------------------
Param($log,$max)
Function Get-log($log,$max)
{
 Get-EventLog -logname $log -newest $max
} #end Get-Log

#TODO: finish Get-AdminRights function
Function Get-AdminRights
{
#TODO: add code to check for administrative 
#TODO: rights. If not running as an admin
#TODO: if possible add code to obtain those rights
} #end Get-AdminRights

If(-not $log) { "You must specify a log name" ; exit}
if(-not $max) { $max = 1 }
#TODO: turn on the if security log check
# If($log -eq "Security") { Get-AdminRights ; exit }
Get-Log -log $log -max $max
