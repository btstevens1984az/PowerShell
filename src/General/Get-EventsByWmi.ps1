# Purpose: Get-EventsByWmi — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------



# DATE: 8/28/2009

#

# KEYWORDS: Get-WmiObject, WMI, Win32_NTLogEvent,

# Foreach-Obejct, Get-Content

#

# COMMENTS: This script reads a text file that contains the 

# names of comptuers on each line. You can edit the script,

# to change the path to the file, or remove Get-Content and

# type in a name such as "localhost". It uses WMI to read

# a specific eventID from a specific event log. By default it

# is reading event ID 21 from the system log which is an

# informational event related to restart after installation of

# an update. 

# ------------------------------------------------------------------------



Param(

   [string[]]$computer = (Get-Content -path c:\fso\servers.txt),

   [string]$log = "system",

   [string]$eventID = 21

) #end param



Function Get-EventsByWmi($computerName,$log,$eventID)

{

 Get-WmiObject -Class win32_NTLogEvent -filter "logfile = '$log' and EventCode = '$eventID'" -computerName $computerName

} #end Get-EventsByWmi



# *** Entry Point to Script ***

if(-not($computer)) {"you must supply name for computer"; exit}

$computer | 

Foreach -begin { "Querying $log Log for EventID: $eventID" } `

  -process { Get-EventsByWmi -ComputerName $_ -log $log -eventID $eventID } `

 -end { "Completed querying $computer.length computers" }