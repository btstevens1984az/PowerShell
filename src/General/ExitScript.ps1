# Purpose: ExitScript — General-purpose PowerShell utilities.
# To leave a PowerShell script, normally you just get to the end and it completes.
# Within functions it is possible to "Return" early from the current 'scope'. This
# can be thought of like a break statement, but for a function.
# The same "return" ability exists within Scripts, but what about if I am in a function
# and wish to bale-out from the script? A bit like the "break from labelled loop", you 
# can force the entire script to exit early, regardless of where we are, via the EXIT statement.

# run as .\ExitScript.ps1
#ExitScript.ps1
#
$dayToIgnore = "Monday"

function Get-PublicSMBInfo() {
 if ( ((get-date).DayOfWeek) -EQ $dayToIgnore ) {
   "I don't work on $dayToIgnore!"
   EXIT
 }
 return ( Get-SMBshare | where {$_.Description -Match "^Public"} )
}

Get-PublicSMBinfo | Format-Table
Write-Host "Will never get here on '$dayToIgnore'!"

