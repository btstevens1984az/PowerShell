# -----------------------------------------------------------------------------------------
# Script: Get-SuspiciousApps.ps1
# Date: August 12, 2015
# Version: 1.0
# Purpose: This script is used query the recently used applications that might contain malware.
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
            'ErrorAction' = 'Stop'
        }
 

        # If we are going to use alternate credentials to access the computer then supply it
        if($FS_Credential) {
            $params.Credential = $FS_Credential
        }

        # Find unusual executables
        $params.Filter = "LastUsedTime <= '$wmidate' AND FolderPath LIKE 'c:\\%' AND NOT ExplorerFileName LIKE '%.exe'"
        $UnusualExeFiles = Get-WmiObject  @params

        # Find startup files
        $params.Filter = "LastUsedTime <= '$wmidate' AND FolderPath LIKE 'c:\\%' AND FolderPath LIKE '%Programs\\Startup%'"
        $StartupFiles = Get-WmiObject  @params

        $SuspiciousApps = @()

        if ($UnusualExeFiles) {

            foreach($UnusualExeFile in $UnusualExeFiles) {
                
                $folderpath = $UnusualExeFile.FolderPath
                $folderpath = $folderpath -replace '\\', '/'

                $unusualfilehash = [ordered]@{
                    'Run Date' = (Get-Date -format F).ToString()                    'Computer Name' = $ComputerName
                    'Company Name' = $UnusualExeFile.CompanyName;
                    'Explorer File Name' = $UnusualExeFile.ExplorerFileName;
                    'Original File Name' = $UnusualExeFile.OriginalFileName;
                    'File Description' = $UnusualExeFile.FileDescription;
                    'Folder Path' = "$folderpath";
                    'File Version' = $UnusualExeFile.FileVersion;
                    'Product Name' = $UnusualExeFile.ProductName;
                    'Last User Name' = $UnusualExeFile.LastUserName;
                    'Last Used Time' = ($UnusualExeFile.ConvertToDateTime($UnusualExeFile.LastUsedTime)).ToString()
                }

                $SuspiciousApps += New-Object -TypeName PSObject -Property $unusualfilehash
                $unusualfilehash = $null
            }
        }

        if ($StartupFiles) {

            foreach ($StartupFile in $StartupFiles) {
                
                $folderpath = $StartupFile.FolderPath
                $folderpath = $folderpath -replace '\\', '/'

                $startupfilehash = [ordered]@{
                    'Run Date' = (Get-Date -format F).ToString()                     'Computer Name' = $ComputerName
                    'Company Name' = $StartupFile.CompanyName;
                    'Explorer File Name' = $StartupFile.ExplorerFileName;
                    'Original File Name' = $StartupFile.OriginalFileName;
                    'File Description' = $StartupFile.FileDescription;
                    'Folder Path' = "$folderpath";
                    'File Version' = $StartupFile.FileVersion;
                    'Product Name' = $StartupFile.ProductName;
                    'Last User Name' = $StartupFile.LastUserName;
                    'Last Used Time' = ($StartupFile.ConvertToDateTime($StartupFile.LastUsedTime)).ToString()

                }

                $SuspiciousApps += New-Object -TypeName PSObject -Property $startupfilehash 
                $startupfilehash  = $null
            }
        }

        $SuspiciousApps
        #$UnusualExeFiles | Sort -Descending
        #$StartupFiles | Sort -Descending

     }
     catch {
       $ExceptionMessage = $_ | format-list -force | Out-String       "Exception generated for $ComputerName"       $ExceptionMessage 
     }
     

}
else {
  
  "Could not connect to computer $ComputerName ...`r`n" 


}