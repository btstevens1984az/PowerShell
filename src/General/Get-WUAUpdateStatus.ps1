# -----------------------------------------------------------------------------------------
# Script: Get-WUAUpdateStatus.ps1
# Date: July 30, 2015
# Version: 1.0
# Purpose: This script is used to get the Windows Update Status on a computer
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



if (Test-Connection -Computer $ComputerName -Count 1 -BufferSize 16 -Quiet ) {


    try {

        # Get the BuildNumber of the computer
        $os_params = @{
            'ComputerName' = $ComputerName;
            'Class' = 'win32_operatingsystem ';
            'Filter' = 'ProductType > "1"';
            'ErrorAction' = 'Stop'
        }

        # If we are going to use alternate credentials to access the computer then supply it

        if($FS_Credential) {
            $os_params.Credential = $FS_Credential
            $networkCred = $FS_Credential.GetNetworkCredential()
        }

        # Get the BuildNumber and ProductType
        $osresults = Get-WmiObject @os_params | Select-Object BuildNumber, ProductType
        #$osresults

        # If we did not get anything, so just  bail out
        if (!$osresults) {
            $message = "The script is designed to run against server and $ComputerName does not seem to be a server.`r`n"
            $message
            return
        }
        # Connect to the registry and see if the computer has pending windows updates        $RegCon = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"LocalMachine",$ComputerName)         # If Vista/2008 & Above query the CBS Reg Key         If ($osresults.BuildNumber -ge 6001) {            $RegSubKeysCBS = $RegCon.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\").GetSubKeyNames()             if ($RegSubKeysCBS -contains "RebootPending" ) {                $CBSRebootPend = $true            }            else {                $CBSRebootPend = $false            }        }        else {            # Query WUAU from the registry             $RegWUAU = $RegCon.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\")             $RegSubKeysWUAU = $RegWUAU.GetSubKeyNames()             if ($RegSubKeysWUAU -contains "RebootRequired" ) {                $WUAURebootReq = $true            }            else {                $WUAURebootReq = $false            }        }        # Closing registry connection         $RegCon.Close()         $wuaupdatestatus = [ordered]@{            'Run Date' = (Get-Date).ToString()            'Computer Name' = $ComputerName        }        # Connect to the computer and query the actual updates        $getupdateparams = @{           'ComputerName' = $ComputerName;
           #'Filter' = 'sourcename = "Microsoft-Windows-WindowsUpdateClient" and EventCode=21';
           'ErrorAction' = 'Stop'        }        if ($CBSRebootPend -or $WUAURebootReq) {            $wuaupdatestatus.'Reboot Pending' = $true            $getupdateparams.Filter = 'logfile = "System" and SourceName = "Microsoft-Windows-WindowsUpdateClient" and EventCode=21'        }        else {            $wuaupdatestatus.'Reboot Pending' = $false            $getupdateparams.Filter = 'logfile = "System" and SourceName = "Microsoft-Windows-WindowsUpdateClient" and EventCode=17'        }        # If this is a desktop computer then query the reliability records        # for servers query the NTLogEvent        if ($osresults.ProductType -ge 1) {                $getupdateparams.Class = 'Win32_NTLogEvent'        }        else {            $getupdateparams.Class = 'Win32_ReliabilityRecords'        }        if($FS_Credential) {
            $getupdateparams.Credential = $FS_Credential
        }

        $getupdates = Get-WmiObject @getupdateparams | Select -First 1
        
        if($getupdates) {
            $wuaupdatestatus.'Category' = $getupdates.CategoryString
            $wuaupdatestatus.'Pending Updates' = $getupdates.Message
            $wuaupdatestatus.'Record Number' = $getupdates.RecordNumber
            $wuaupdatestatus.'Time Generated' = $($getupdates.ConvertToDateTime($getupdates.TimeGenerated)).ToString()
            $wuaupdatestatus.'Time Written' = $($getupdates.ConvertToDateTime($getupdates.TimeWritten)).ToString()
        }
        else {

            $wuaupdatestatus.'Category' = ''
            $wuaupdatestatus.'Pending Updates' = ''
            $wuaupdatestatus.'Record Number' = ''
            $wuaupdatestatus.'Time Generated' = ''
            $wuaupdatestatus.'Time Written' = ''
        }
                New-Object -TypeName PSObject -Property $wuaupdatestatus        

     }
     catch {
         $ExceptionMessage = $_ | format-list -force | Out-String       "Exception generated for $ComputerName"       $ExceptionMessage
     }
     

}
else {
  
  "Could not connect to computer $ComputerName ...`r`n" 


}