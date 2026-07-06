# -----------------------------------------------------------------------------------------
# Script: Get-RecentApps.ps1
# Date: August 12, 2015
# Version: 1.0
# Purpose: This script is used query the recently used applications on a computer.
#          It requires the CCM Software Metering Agent
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

        if($FS_Credential) {
            $os_params.Credential = $FS_Credential
        }

        $OSVersion = (Get-WmiObject @os_params).version 

        # If we did not get anything, ie not client computer bail out.
        if (!$OSVersion) {
            $message = "$ComputerName is running a Server Operating System.`r`n"
            $message += "This script can only be used to retrieve the members of the local Administrator group on Desktop computers.`r`n"
            $message
            return
        }

        # Check if the Software Metering Agent Namespace exists it is installed under the root\ccm
        $checknamespace = @{
            'ComputerName' = $ComputerName;
            'NameSpace' =  'root';
            'Class' = '__NAMESPACE';
            'Filter' = "Name = 'ccm'"
            'ErrorAction' = 'Stop'
        }

        if($FS_Credential) {
            $checknamespace.Credential = $FS_Credential
        }

        if (!(Get-WmiObject  @checknamespace)) {
            "The CCM Recently Used Apps Class is required by this script and it is not installed on $ComputerName"
            return
        }

        $wmidate = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-Date).AddHours(-24))
    
        $params = @{
            'ComputerName' = $ComputerName;
            'NameSpace' =  'root\ccm\SoftwareMeteringAgent';
            'Class' = 'CCM_RecentlyUsedApps';
            #'Filter' = "LastUsedTime <= '$wmidate' AND LaunchCount > 100"
            'Filter' = "LastUsedTime <= '$wmidate'"
            'ErrorAction' = 'Stop'
        }
 

        # If we are going to use alternate credentials to access the computer then supply it
        if($FS_Credential) {
            $params.Credential = $FS_Credential
        }

        $RecentlyUsedFiles = Get-WmiObject  @params

        $RecentApps = @()

        if ($RecentlyUsedFiles) {

            foreach($RecentlyUsedFile in $RecentlyUsedFiles) {
                
                $folderpath = $RecentlyUsedFile.FolderPath
                $folderpath = $folderpath -replace '\\', '/'

                $recentfilehash = [ordered]@{
                    'Run Date' = (Get-Date -format F).ToString()                    'Computer Name' = $ComputerName
                    'Company Name' = $RecentlyUsedFile.CompanyName;
                    'Explorer File Name' = $RecentlyUsedFile.ExplorerFileName;
                    'Original File Name' = $RecentlyUsedFile.OriginalFileName;
                    'File Description' = $RecentlyUsedFile.FileDescription;
                    'Folder Path' = "$folderpath";
                    'File Version' = $RecentlyUsedFile.FileVersion;
                    'Product Name' = $RecentlyUsedFile.ProductName;
                    'Last User Name' = $RecentlyUsedFile.LastUserName;
                    'Last Used Time' = ($RecentlyUsedFile.ConvertToDateTime($RecentlyUsedFile.LastUsedTime)).ToString()
                }

                $RecentApps += New-Object -TypeName PSObject -Property $recentfilehash
                $recentfilehash = $null
            }
        }


        $RecentApps

     }
     catch {
       $ExceptionMessage = $_ | format-list -force | Out-String       "Exception generated for $ComputerName"       $ExceptionMessage 
     }
     

}
else {
  
  "Could not connect to computer $ComputerName ...`r`n" 


}