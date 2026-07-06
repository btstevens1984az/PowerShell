# -----------------------------------------------------------------------------------------
# Script: Invoke-ShutdownComputer.ps1
# Date: October 1, 2015
# Version: 1.0
# Purpose: This script is used to shutdown local and remote computers.
#
#
# Project: foreScript
#
# -----------------------------------------------------------------------------------------
#
# (C) Nigel Thomas, 2015
#
#------------------------------------------------------------------------------------------

<#
    .SYNOPSIS        Shutdown local and remote computers.
        .DESCRIPTION        Uses the Stoop-Computer 81.118.44.78 to shutdown a local or remote computer

    .PARAMETER ComputerName
        The computer to shutdown


    .Link 
        https://toolsmith.brycoretechnologies.com
#>


#Requires -version 3

[Cmdletbinding()]
Param (
    $ComputerName
)


if (Test-Connection -Computer $ComputerName -Count 1 -BufferSize 16 -Quiet ) {


    try {
    
        # Get the CSName for client computers.
        # ProductType = 1 designate a desktop computer
        $os_params = @{
            'ComputerName' = $ComputerName;
            'Class' = 'win32_operatingsystem ';
            'Filter' = 'ProductType = "1"';
            'ErrorAction' = 'Stop'
        }

        # If we are going to use alternate credentials to access the computer then supply it

        if($FS_Credential) {
            $os_params.Credential = $FS_Credential
        }

        # Get the name of the computer
        $CSName = (Get-WmiObject @os_params).CSName

        # If we did not get anything, ie not client computer bail out, or just could not get the name then bail out
        if (!$CSName) {
            $message = "$ComputerName is running a Server Operating System.`r`n"
            $message += "This script can only be used to shutdown a Desktop Computer.`r`n"
            $message
            return
        }

        $shutdown_params = @{
            'ComputerName' = $ComputerName;
            'ErrorAction' = 'Stop'
        }

        if($FS_Credential) {
            $shutdown_params.Credential = $FS_Credential
        }

        $Shutdownobj = [ordered]@{
            'Computer' = $ComputerName
        }

        # We will start a stopwatch and run it for 5 minutes. If the computer does not 
        # shutdown in 5 minutes we will report it as an error

        Stop-Computer @shutdown_params

        $elapsedtime = [System.Diagnostics.Stopwatch]::StartNew()
        $ping = New-Object System.Net.NetworkInformation.Ping        $shutdownevent = $true        while ($shutdownevent) {            $result = $ping.Send($ComputerName)            if ($result.Status -eq "TimedOut") {                $Shutdownobj.ShutDown = 'Ok'                $Shutdownobj.Online = $false                $shutdownevent = $false            }            if ($elapsedtime.ElapsedMilliseconds -ge 300000) {                $Shutdownobj.ShutDown = 'Error'                $Shutdownobj.Online = $true                $elapsedtime.Stop()                break            }        }        
        $elapsedtime.Reset()

        $Shutdownobj

     }
     catch {
  
       $ExceptionMessage = $_ | format-list -force | Out-String       "Exception generated for $ComputerName"       $ExceptionMessage 
     }
     

}
else {
  
  "Could not connect to computer $ComputerName ...`r`n" 


}