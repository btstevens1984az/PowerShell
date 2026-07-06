# -----------------------------------------------------------------------------------------
# Script: Test-StartuplOcations.ps1
# Date: August 10, 2015
# Version: 1.0
# Purpose: This script is used to review the startup locations in the Windows Registry for indication
#          of Malware infestations
# Project: foreScript
#
# -----------------------------------------------------------------------------------------
#
# (C) Nigel Thomas, 2015
#
#------------------------------------------------------------------------------------------

#Requires -version 3


[CmdletBinding()]
 Param (
    $ComputerName = $env:COMPUTERNAME
    
 )

$StartupLocationsFile = 'c:\psscripts\startuplocations.txt'
if (Test-Path $StartupLocationsFile) {
    $StartupLocations = Get-Content -Path $StartupLocationsFile 
    #$StartupLocations
}

else {
    $message = "The file with the list of Windows Registry Startup Locations could not be found at $StartupLocationsFile."
    $message
    return
}



if (Test-Connection -Computer $ComputerName -Count 1 -BufferSize 16 -Quiet ) {


    try {

        # Get the BuildNumber of the computer
        $os_params = @{
            'ComputerName' = $ComputerName;
            'Class' = 'win32_operatingsystem ';
            'Filter' = 'ProductType = "1"';
            'ErrorAction' = 'Stop'
        }

        # If we are going to use alternate credentials to access the computer then supply it

        if($FS_Credential) {
            $os_params.Credential = $FS_Credential
            $networkCred = $FS_Credential.GetNetworkCredential()
        }

        # Get the BuildNumber and ProductType
        $osresults = Get-WmiObject @os_params | Select-Object BuildNumber, ProductType, OSArchitecture
        #$osresults

        # If we did not get anything, so just  bail out
        if (!$osresults) {
            $message = "$ComputerName is running a Server Operating System.`r`n"
            $message += "This script can only be used to retrieve the common Startup Locations in the Windows Registry on Desktop Computers.`r`n"
            $message
            return
        }
        # Connect to the registry and check the startup loctions        $RegCon = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"LocalMachine",$ComputerName)         # Closing registry connection         $RegCon.Close()         

     }
     catch {
         $ExceptionMessage = $_ | format-list -force | Out-String       "Exception generated for $ComputerName"       $ExceptionMessage
     }
     

}
else {
  
  "Could not connect to computer $ComputerName ...`r`n" 


}