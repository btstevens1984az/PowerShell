# Purpose: LocalScope — General-purpose PowerShell utilities.
#LocalScope.ps1
#
 $time = get-date
 $day  = (get-date).day

 function get-theTime() {
   #create a local $time variable
   $time=(get-date).Minute
   $milli = (get-date).Millisecond
   write-output "Function: '`$Time'  variable is $time"
   write-output "Function: '`$day'   variable is $day"
   write-output "Function: '`$milli' variable is $milli"
 }

 get-theTime
 write-output "Script:   '`$Time'  variable is $time"
 write-output "Script:   '`$Day'   variable is $day"
 write-output "Script:   '`$milli' variable is $milli"
 Write-output "NOTE: '`$milli' only existed within the life of the function call."