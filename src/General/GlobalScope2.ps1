# Purpose: GlobalScope2 — General-purpose PowerShell utilities.
#GlobalScope2.ps1

 function Get-GlobalVar() {
   write-output "Function: '`$MYGLOBAL' has a value of $MYGLOBAL"
 }

 function Set-GlobalVar() {
   $global:MYGLOBAL="aNewValueForGlobal"
   write-output "Function: '`$MYGLOBAL' has a value of $MYGLOBAL"
 }
 write-output "'`$HOME'                   is: $HOME"
 write-output "'`$PSCULTURE'              is: $PSCULTURE"
 write-output "'`$ERRRORACTIONPREFERENCE' is: $ERRORACTIONPREFERENCE"
 write-output "'`$MYGLOBAL'               is: $MYGLOBAL"
 write-output " "
 write-output "Script:   '`$MYGLOBAL' has a value of $MYGLOBAL"
 
 Get-GlobalVar
 write-output "NOTE: the global variable has been accessed from a separate script!"
 write-output " "

 Set-GlobalVar
 write-output "Script:   '`$MYGLOBAL' now has a value of $MYGLOBAL"
 write-output "NOTE: the global variable has been set from a separate script!"

