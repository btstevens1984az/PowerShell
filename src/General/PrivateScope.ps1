# Purpose: PrivateScope — General-purpose PowerShell utilities.
#PrivateScope.ps1
 $time = get-date
 $Private:Pday = (get-date).Day

# new-variable -name Pday -Option private -Value (get-date).day

 function Look-AtVars() {
   write-output "Function: '`$time' is viewable and has a value of $time"
   write-output "Function: '`$Pday' is private and has a value of $Pday"
 }

 write-output "Script:   '`$time' is viewable and has a value of $time"
 write-output "Script:   '`$Pday' is private and has a value of $Pday"
 Look-AtVars
 write-output "NOTE: the Pday was not viewable from within the function!"
