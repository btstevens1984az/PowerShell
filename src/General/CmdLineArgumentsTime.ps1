# Purpose: CmdLineArgumentsTime — General-purpose PowerShell utilities.
#INPROGRESS: change unnamed arguments to a more user friendly method
[int]$inthour = $args[0]
[int]$intMinute = $args[1]
#INPROGRESS: find a better way to check for existance for powergadgets
#This causes errors to be ignored and is used when checking for PowerGadgets
$erroractionpreference = "SilentlyContinue"
#this clears all errors and is used to see if errors are present.
$error.clear()
#This command will generate an error if PowerGadgets are not installed
Get-PSSnapin *powergadgets | Out-Null
#INPROGRESS: Prompt before loading powergadgets
If ($error.count -ne 0)
{Add-PSSnapin powergadgets} 

New-TimeSpan -Start (get-date) -end (get-date -Hour $inthour -Minute $intMinute) | 
Out-Gauge -Value minutes -Floating -refresh 0:0:30  -mainscale_max 60