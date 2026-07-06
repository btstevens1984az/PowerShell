# Purpose: CheckService — Windows desktop configuration and management.
# ------------------------------------------------------------------------
# DATE: 12/14/2008
#
# KEYWORDS: Get-Service, where-object, if, else
# compound where clause
# COMMENTS: This script checks the status of a service
#
#
#
#
# ------------------------------------------------------------------------
$serviceName = "ZuneBusEnum"
if(
   Get-Service | 
   Where-Object { $_.status -eq 'running' -AND $_.name -eq $serviceName }
  )
 {
  "$serviceName is running"
 } #end if
ELSE
 {
  "$serviceName is not running"
 } #end else
