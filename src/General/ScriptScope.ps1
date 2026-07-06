# Purpose: ScriptScope — General-purpose PowerShell utilities.
#ScriptScope.ps1

 $time = get-date

 function Set-ScriptVar() {
   $time = 1200
   write-output "Function: '`$time' has a value of $time"
   write-output "Function: script level '`$time' has a value of $script:time"
   $time = 1300
   $script:time = (get-date).AddYears(-6)
   write-output "Function: altered value of '`$time' to $time"
   write-output "Function: altered value of script level '`$time' to $script:time"
 }

 write-output "Script:   '`$time' has a value of $time"
 Set-ScriptVar
 write-output "Script:   '`$time' has a value of $time"
 write-output "NOTE: the year was changed from within the function"
