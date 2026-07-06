# -----------------------------------------------------------------------------------------
# Script: Get-AntivirusProducts.ps1
# Date: May 4, 2015
# Version: 1.0
# Purpose: This script is used query the status of the Antivirus Product on desktop computers
#
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

        # Get the OS version for client computers.
        # ProductType = 1 designate a desktop computer
        $os_params = @{
            'ComputerName' = $ComputerName;
            'Class' = 'win32_operatingsystem ';
            'Filter' = 'ProductType = "1"';
            'ErrorAction' = 'Stop'
        }

        # If we are going to use alternate credentials to access the computer then supply it

        if($cred) {
            $os_params.Credential = $cred
        }

        $OSVersion = (Get-WmiObject @os_params).version 

        # If we did not get anything, ie not client computer bail out.
        if (!$OSVersion) {
            return
        }

        $OS = $OSVersion.split(".")
    
        # Get the Antivirus product information
        $params = @{
            'ComputerName' = $ComputerName;
            'Class' = 'AntivirusProduct';
            'ErrorAction' = 'Stop'
        }

        if ($OS[0] -eq "5") {
            $params.Namespace = 'root\SecurityCenter'
        }
        else {
            $params.Namespace = 'root\SecurityCenter2'
        }

        # If we are going to use alternate credentials to access the computer then supply it

        if($cred) {
            $params.Credential = $cred
        }


        $AntiVirusProduct = Get-WmiObject  @params

        if ($AntiVirusProduct) {

            #The values in this switch-statement are retrieved from the following website: http://community.kaseya.com/resources/m/knowexch/1020.aspx             switch ($AntiVirusProduct.productState) {                                 "262144" {$defstatus = "Up to date" ;$rtstatus = "Disabled"}                 "262160" {$defstatus = "Out of date" ;$rtstatus = "Disabled"}                 "266240" {$defstatus = "Up to date" ;$rtstatus = "Enabled"}                 "266256" {$defstatus = "Out of date" ;$rtstatus = "Enabled"}                 "393216" {$defstatus = "Up to date" ;$rtstatus = "Disabled"}                 "393232" {$defstatus = "Out of date" ;$rtstatus = "Disabled"}                 "393488" {$defstatus = "Out of date" ;$rtstatus = "Disabled"}                 "397312" {$defstatus = "Up to date" ;$rtstatus = "Enabled"}                 "397328" {$defstatus = "Out of date" ;$rtstatus = "Enabled"}                 "397584" {$defstatus = "Out of date" ;$rtstatus = "Enabled"}                 default {$defstatus = "Unknown" ;$rtstatus = "Unknown"}             }            #Create hash-table for each computer             $ht = [ordered]@{}             $ht.'Computer Name' = $ComputerName            $ht.'Antivirus Name' = $AntiVirusProduct.displayName             $ht.'Product Executable' = $AntiVirusProduct.pathToSignedProductExe             $ht.‘Definition Status’ = $defstatus             $ht.‘Real-time Protection Status’ = $rtstatus                     #Create a new object for each computer             New-Object -TypeName PSObject -Property $ht         } 

     }
     catch {
       $ExceptionMessage = $_ | format-list -force | Out-String       "Exception generated for $ComputerName"       $ExceptionMessage 
     }
     

}
else {
  
  "Could not connect to computer $ComputerName ...`r`n" 


}