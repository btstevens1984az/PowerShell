# Purpose: Get-UpdateLog — General-purpose PowerShell utilities.
﻿Function Get-UpdateLog {
[cmdletbinding()]
Param (
    [parameter()]
    [string[]]$Computername,
    [parameter()]
    [int32]$Last
    )
Begin {
    }
Process{    
    ForEach ($computer in $computername) {
        $logpath = "$((gwmi -computer $computer win32_operatingsystem).WindowsDirectory)\WindowsUpdate.log"
        $updatelog = "\\{0}\{1}" -f $computer,($logpath -replace ":","$")
        If ($PSBoundParameters['Last']) {    
            [array]$log = get-content $updatelog |
                Select -Last $last
            }
        Else {
            [array]$log = get-content $updatelog
            }
        ForEach ($line in $log) {
            $split = $line -split "`t"
            $hash = @{
                Computer = $computer
                Date = $split[0]
                Time = $split[1]
                Type = $split[4]
                Message = $split[5]
                }
            $object = New-Object PSObject -Property $hash
            $object.PSTypeNames.Insert(0,'UpdateLog')
            $object
            }
        }
    }
End {
    }
}
