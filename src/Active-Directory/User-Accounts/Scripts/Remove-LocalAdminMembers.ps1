Function Remove-LocalAdminMembers {
# -----------------------------------------------------------------------------------------
# Script: Remove-LocalAdminMembers.ps1
# Date: July 31, 2015
# Version: 1.0
# Purpose: This script is used to remove members from the local adminstrators group. Except for specified users
#------------------------------------------------------------------------------------------
#Requires -version 3


[CmdletBinding()]
 Param (
    $ComputerName = $env:COMPUTERNAME
    
 )

$LocalAdminsFile = 'C:\Temp\localadmins.txt'
if (Test-Path $LocalAdminsFile) {
    $LocalAdmins = Get-Content -Path $LocalAdminsFile
    #$LocalAdmins
}

else {
    $message = "The file with the list of local administrators could not be found at $LocalAdminsFile ."
    $message
    return
}

$eventid4733 = '<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">*[System[(EventID=4733)]]</Select>
  </Query>
</QueryList>'

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
        }        # Get the local administrators group        $findadmingroup = Get-WmiObject @findadminparams        $admingroupname = $findadmingroup.Name        $admingroup = [adsi]("WinNT://$ComputerName/$admingroupname,Group")        $removeadminmemberresults = @()        if ($findadmingroup) {            # Get the members of the group based on http://blogs.technet.com/b/heyscriptingguy/archive/2013/12/08/weekend-scripter-who-are-the-administrators.aspx
            $wmiEnumOpts = New-Object System.Management.EnumerationOptions
            $wmiEnumOpts.BlockSize = 20
            $admingroupmembers = $findadmingroup.GetRelated("Win32_Account","Win32_GroupUser","","", "PartComponent","GroupComponent",$false,$wmiEnumOpts)            #$admingroupmembers            if($admingroupmembers) {                                # Get the members of the local admin group and compare it agains the local admin file and the administrator SID                # If the local admin file is empty we will remove all users from the local administrator group                foreach($member in $admingroupmembers) {                    if($LocalAdmins.Length -gt 0) {                        #$LocalAdmins.Length                                                if (($member.SID -notlike "S-1-5-21-*-500") -and ($member.Name -notin $LocalAdmins)) {                             #$member.Name                                                         $admingroup.Remove("WinNT://" + $member.Domain + "/" + $member.Name)                             $removeadmingmemberhash = [ordered]@{                                'Run Date' = (Get-Date -format F).ToString()                                'Computer Name' = $ComputerName                                'Local Administrator Group' = $findadmingroup.Name                                'Removed Member' = $member.Caption                                'Removed Member SID' = $member.SID                             }

                             $removeadminmemberresults += New-Object -TypeName PSObject -Property $removeadmingmemberhash                             $removeadmingmemberhash = $null                                                       }                                                                   }                    else {                        if (($member.SID -notlike "S-1-5-21-*-500")) {                            #$member                                                        $admingroup.Remove("WinNT://" + $member.Domain + "/" + $member.Name)                            $removeadmingmemberhash = [ordered]@{                                'Run Date' = (Get-Date -format F).ToString()                                'Computer Name' = $ComputerName                                'Local Administrator Group' = $findadmingroup.Name                                'Removed Member' = $member.Caption                                'Removed Member SID' = $member.SID                            }

                            $removeadminmemberresults += New-Object -TypeName PSObject -Property $removeadmingmemberhash                            $removeadmingmemberhash = $null                        }                    }                                    }            }                    }               $removeadminmemberresults

     }
     catch {
         $ExceptionMessage = $_ | format-list -force | Out-String       "Exception generated for $ComputerName"       $ExceptionMessage
     }
     

}
else {
  
  "Could not connect to computer $ComputerName ...`r`n" 


}
}