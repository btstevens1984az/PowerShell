# Purpose: timesync — General-purpose PowerShell utilities.
#
#
# timesync.ps1

function sync-time(  
 [string] $server = "146.150.205.213",

      [int] $port = 37,

      [switch] $set = $false)

    {

      $servertime = get-time -server $server -port $port -set:$set

      write-host "Server time:" $servertime 

       write-host "Local time :" $(date)

    }

