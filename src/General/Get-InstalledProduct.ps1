# -----------------------------------------------------------------------------------------
# Script: Get-InstalledProduct.ps1
# Date: May 4, 2015
# Version: 1.0
# Purpose: This script is used query the status of an installed product on desktop computers
#
# Project: foreScript
#
# -----------------------------------------------------------------------------------------
#
# (C) Nigel Thomas, 2015
#
#------------------------------------------------------------------------------------------

<#
    .SYNOPSIS        Queries a local or remote desktop computer for an installed application.
        .DESCRIPTION        Uses the System Management Classes to check if an application is installed on a local or remote desktop computer. The System
        Management Classes is used instead of the WMI Win32_Product Class, because the Win32_Product Class is ging to enumerate
        all of the applications installed on the computer and run the reconfigure option on each installed application. This can potential
        affect the installation of application and slows down the retreival of the application information.

    .PARAMETER GUID
        The installed Product GUID.

    .PARAMETER Name
        The installed Product name.

    .PARAMETER Version
        The installed Product version.

    .Example
        Get-InstalledProduct.ps1 -GUID {109A5A16-E09E-4B82-A784-D1780F1190D6} -Name Windows Firewall Configuration Provider -Version 1.2.3412.0

    .Link 
        https://toolsmith.brycoretechnologies.com
#>

#Requires -version 3

[CmdletBinding()]
 Param (
    $ComputerName = $env:COMPUTERNAME,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$GUID,
    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Name,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Version
    
 )


if (Test-Connection -Computer $ComputerName -Count 1 -BufferSize 16 -Quiet ) {


    try {

        

        $opt = New-CimSessionOption -Protocol DCOM        $sessparams = @{            'ComputerName' = $ComputerName;            'SessionOption' = $opt;            'ErrorAction' = 'Stop'        }        # If we are going to use alternate credentials to access the computer then supply it        if ($cred) {            $sessparams.Credential = $cred        }        $csd = New-CimSession @sessparams

        # Get the OS version for client computers.
        # ProductType = 1 designate a desktop computer
        $os_params = @{
            'Class' = 'Win32_OperatingSystem ';
            'CimSession' = $csd;
            'Filter' = 'ProductType = "1"';
            'ErrorAction' = 'Stop'
        }


        $OSVersion = (Get-CimInstance @os_params).version 

        # If we did not get anything, ie not client computer bail out.
        if (!$OSVersion) {
            return
        }

    
        # We are going to use the System.Management classes to get the product instead of the
        # Win32_product class. This is because the Win32_Product class is going to enumerate 
        # all of the installed products on the computer and run the reconfigure option on all of them.
        # This will slow down getting the product information and the reconfiguration of sofwtare on production
        # computers could be an issue

        # Code based on http://stackoverflow.com/questions/3577338/using-wmi-to-uninstall-applications-remotely
        $connoptions = New-Object System.Management.ConnectionOptions

        if ($cred) {

            $networkCred = $cred.GetNetworkCredential()
            $connoptions.Username=$networkCred.Domain.ToString() + "\" + $networkCred.UserName.ToString()            $connoptions.Password=$networkCred.Password
        }
                $connoptions.Authentication=[System.Management.AuthenticationLevel]::PacketPrivacy        #$co.EnablePrivileges=$true        $scope = New-Object System.Management.ManagementScope("\\$ComputerName\root\cimv2", $connoptions)        $scope.Connect()        #$objoptions = New-Object System.Management.ObjectGetOptions        # Win32_Product management objects can be accessed in the format of         # Win32_Product.IdentifyingNumber="",Name="",version=""        #$objPath = "Win32_Product.IdentifyingNumber=`"`{109A5A16-E09E-4B82-A784-D1780F1190D6`}`",Name=`"Windows Firewall Configuration Provider`",version=`"1.2.3412.0`""        $objPath = "Win32_Product.IdentifyingNumber=`"$GUID`",Name=`"$Name`",version=`"$Version`""        #$objPath        $path = New-Object System.Management.ManagementPath($objPath)        $InstalledProduct = New-Object System.Management.ManagementObject($scope, $path, $null)

        #$InstalledProduct

        if ($InstalledProduct) {                        # An error occured            if ($InstalledProduct.Message) {                                "$objPath not found on $ComputerName `r`n"                return            }            #Create hash-table for each computer             $ht = [ordered]@{}             $ht.'Computer Name' = $ComputerName            $ht.'Identifying Number' = $InstalledProduct.IdentifyingNumber            $ht.'Name' = $InstalledProduct.Name            $ht.'Description' = $InstalledProduct.Description            $ht.‘Install Date’ = $InstalledProduct.InstallDate            $ht.‘Vendor’ = $InstalledProduct.Vendor            $ht.‘Version’ = $InstalledProduct.Version                    #Create a new object for each computer             New-Object -TypeName PSObject -Property $ht        }

     }
     catch {
  
       if ($_.Exception.InnerException) {            $ExceptionMessage = $_.Exception.InnerException       }       else {             $ExceptionMessage = $_.Exception.Message       }       $ExceptionMessage
       
     }
     

}
else {
  
  "Could not connect to computer $ComputerName ...`r`n" 


}