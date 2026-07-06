# -----------------------------------------------------------------------------------------
# Script: Get-LocalAdminMembers.ps1
# Date: July 23, 2015
# Version: 1.0
# Purpose: This script is used to get the members of the local Administrators group on a computer
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
            $message += "This script can only be used to retrieve the members of the local Administrator group on Desktop computers.`r`n"
            $message
            return
        }
        # Find the local administrator group. We will use the well know SID for the local administrators group        $findadminparams = @{            'ComputerName' = $ComputerName;
            'Class' = 'Win32_Group';
            'Filter' = 'LocalAccount = TRUE and SID="S-1-5-32-544"';
            'ErrorAction' = 'Stop'        }        if($FS_Credential) {
            $findadminparams.Credential = $FS_Credential
        }        # Get the local administrators group        $findadmingroup = Get-WmiObject @findadminparams        $findadmingroupresults = @()                if ($findadmingroup) {
           
            # Get the members of the group based on http://blogs.technet.com/b/heyscriptingguy/archive/2013/12/08/weekend-scripter-who-are-the-administrators.aspx
            $wmiEnumOpts = New-Object System.Management.EnumerationOptions
            $wmiEnumOpts.BlockSize = 20
            $admingroupmembers = $findadmingroup.GetRelated("Win32_Account","Win32_GroupUser","","", "PartComponent","GroupComponent",$false,$wmiEnumOpts)
            if ($admingroupmembers) {
                foreach ($member in $admingroupmembers) {

                    $findadmingrouphash = [ordered]@{                        'Run Date' = (Get-Date -format F).ToString()                        'Computer Name' = $ComputerName                        'Local Administrator Group Name' = $findadmingroup.Name                        'Domain' = $member.Domain                        'Members of Group' = $member.Caption                        'SID' = $member.SID                    }

                    $findadmingroupresults += New-Object -TypeName PSObject -Property $findadmingrouphash

                    $findadmingrouphash = $null
                    
                }
            }
        }        else {            $findadmingrouphash = [ordered]@{                 'Date' = (Get-Date -format F).ToString()                 'Computer Name' = $ComputerName                 'Local Administrator Group Name' = ''                 'Domain' = ''                 'Members of Group' = ''                 'SID' = ''            }

            $findadmingroupresults += New-Object -TypeName PSObject -Property $findadmingrouphash            $findadmingrouphash = $null        }        $findadmingroupresults        

     }
     catch {
         $ExceptionMessage = $_ | format-list -force | Out-String       "Exception generated for $ComputerName"       $ExceptionMessage
     }
     

}
else {
  
  "Could not connect to computer $ComputerName ...`r`n" 


}