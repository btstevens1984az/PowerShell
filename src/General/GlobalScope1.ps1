# Purpose: GlobalScope1 — General-purpose PowerShell utilities.
#GlobalScope1.ps1

 write-output "'`$HOME'                   is: $HOME"
 write-output "'`$PSCULTURE'              is: $PSCULTURE"
 write-output "'`$ERRRORACTIONPREFERENCE' is: $ERRORACTIONPREFERENCE"
 write-output " "
 $global:MYGLOBAL="MyGlobalVariable"
 write-output "'`$MYGLOBAL'               is: $MYGLOBAL"
 write-output "NOTE: Global '`$MYGLOBAL' will be viewable in other scripts and functions"
 write-output " "
 write-output "Try this: Get-Variable -Scope Global"