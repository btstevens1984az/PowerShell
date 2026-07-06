# -----------------------------------------------------------------------------------------
# Script: Add-LocalAdmininistrator.ps1
# Date: July 21, 2015
# Version: 1.0
# Purpose: This script is used add an administrative acount to the local administrator group on desktop computers.
#          Based on best practices at https://technet.microsoft.com/en-us/library/cc733008.aspx
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
    $ComputerName = $env:COMPUTERNAME,
    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $PasswordString,
    
    [Parameter(Mandatory=$true)]     
    [ValidateNotNullOrEmpty()]
    $AddAdministrator
 )



# Get the event id 4724 and 4728 created within the last hour. These evenets are created when a users password is reset.

$query4724 = '
     <QueryList>
    <Query Id="0" Path="Security">
    <Select Path="Security">*[System[(EventID=4724) and TimeCreated[timediff(@SystemTime) &lt;= 3600000]]]</Select>
   </Query>
   </QueryList>
'
$query4738 = '
     <QueryList>
     <Query Id="0" Path="Security">
     <Select Path="Security">*[System[(EventID=4738) and TimeCreated[timediff(@SystemTime) &lt;= 3600000]]]</Select>
     </Query>
    </QueryList>
'

# Enable or disbale flags
$Disabled = 0x002
$PasswordNotRequired = 0x020

# http://www.nathandavison.com/article/2/password-salt-and-hashing-in-c
function HashPassword  {

    Param (
    
        [string]$PasswordString,
        [string]$SaltValue

    )

    $hasher = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($PasswordString, [System.Text.Encoding]::Default.GetBytes($SaltValue), 24000)
    return [System.Convert]::ToBase64String($hasher.GetBytes(16))
}

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
            $message = "$Computer is running a Server Operating System.`r`n"
            $message += "This script can only be used to reset the Administrator password on Desktop computers.`r`n"
            $message
            return
        }
        # Do a search to find out if the account we want to add exists.        $findaccountparams = @{            'ComputerName' = $ComputerName;
            'Class' = 'Win32_UserAccount';
            'Filter' = "LocalAccount = TRUE and Name like '$AddAdministrator'";
            'ErrorAction' = 'Stop'        }        if($FS_Credential) {
            $findaccountparams.Credential = $FS_Credential
        }        # Get the local account        $findaccount = (Get-WmiObject @findaccountparams).Name        $addaccountresults = [ordered]@{            'Date' = (Get-Date -format F).ToString()            'Computer Name' = $ComputerName        }        $newadmin = ''        if ($findaccount) {
            
            $newadmin = [ADSI]("WinNT://$ComputerName/$findaccount,User")
            $addaccountresults.'Local Administrator Account' = $newadmin.Name.ToString()
        }

        else {

            $cn = [ADSI]("WinNT://$ComputerName,Computer")
  
            $newadmin = $cn.Create("User", $AddAdministrator)
            $newadmin.SetInfo()

            $addaccountresults.'Local Administrator Account' = $newadmin.Name.ToString()
    
            $newadmin.Put('Description', 'Local Administrative Account')
            $newadmin.SetInfo()

        }        # Set the password        #$TheNewPassword = Invoke-Expression $PasswordString        $TheNewPassword = HashPassword -PasswordString $PasswordString -SaltValue $CSName         #$TheNewPassword         $BSTR = [system.runtime.interopservices.marshal]::StringToBSTR($TheNewPassword )        $NewPassword= [system.runtime.interopservices.marshal]::PtrToStringAuto($BSTR)        $newadmin.SetPassword(($NewPassword))
        $newadmin.SetInfo()        $addaccountresults.'New Password' = $TheNewPassword         [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)                 # Check if the user is in the local administrators group        $findadminparams = @{
            'ComputerName' = $ComputerName;
            'Class' = 'Win32_Group';
            'Filter' = 'LocalAccount = TRUE and SID="S-1-5-32-544"';
            'ErrorAction' = 'Stop'        }        if($FS_Credential) {
            $findadminparams.Credential = $FS_Credential
        }                # Get the local administrators group        $findadmingroup = Get-WmiObject @findadminparams


        # Get the members of the group based on http://blogs.technet.com/b/heyscriptingguy/archive/2013/12/08/weekend-scripter-who-are-the-administrators.aspx
        $wmiEnumOpts = New-Object System.Management.EnumerationOptions
        $wmiEnumOpts.BlockSize = 20
        $accountisadmin = $findadmingroup.GetRelated("Win32_Account","Win32_GroupUser","","", "PartComponent","GroupComponent",$false,$wmiEnumOpts)
        #$accountisadmin.Name
            
        if ($AddAdministrator -notin $accountisadmin.Name) {                    $admingroupname = $findadmingroup.Name            #$admingroupname            $admingroup = [adsi]("WinNT://$ComputerName/$admingroupname,Group")
            $admingroup.Add($newadmin.Path)
            $admingroup.SetInfo()
            $addaccountresults.'Local Admin Group' = $findadmingroup.Name.ToString()
            $addaccountresults.'Add to Local Admin Group' = 'Membership New'
        }
        else {
            $addaccountresults.'Local Admin Group' = $findadmingroup.Name.ToString()
            $addaccountresults.'Add to Local Admin Group' = 'Membership Exists'
        }

        # Enable the  account and require a password for the user
        $newadmin.userflags.value = $newadmin.UserFlags.value -BOR $Disabled
        $newadmin.SetInfo()
        $newadmin.userflags.value = $newadmin.UserFlags.value -BXOR $Disabled
        $newadmin.SetInfo()
        $newadmin.userflags.value = $newadmin.UserFlags.value -BOR $PasswordNotRequired
        $newadmin.SetInfo()
        $newadmin.userflags.value = $newadmin.UserFlags.value -BXOR $PasswordNotRequired
        $newadmin.SetInfo()

        # Halt the script. Need to do this so that event log gets updated on remote computer
        #Sleep 5
        
        # Query event log for password change messages
        $passwdchangeparams = @{
            'ComputerName' = $ComputerName
            'FilterXml' = $query4724
            'MaxEvents' = 1
            'ErrorAction' = 'Stop'
        }

        if($FS_Credential) {
            $passwdchangeparams.Credential = $FS_Credential
        }
        
        $addaccountresults.'Security Event ID 4724' = (Get-WinEvent @passwdchangeparams | Select -First 1).Message

        $passwdchangeparams = @{
            'ComputerName' = $ComputerName
            'FilterXml' = $query4738
            'MaxEvents' = 1
            'ErrorAction' = 'Stop'
        }
        
        if($FS_Credential) {
           $passwdchangeparams.Credential = $FS_Credential
        }

        $addaccountresults.'Security Event ID 4738' = (Get-WinEvent @passwdchangeparams | Select -First 1).Message        

        
        # Test that the password was changed by mapping the ADMIN$ share on the computer as the 
        # local administrator with the new password
        #$remotehost = ("\\{0}\admin`$") -f $ComputerName
        #$remoteuser = ("{0}\{1}") -f $Computer, $newadmin.Name.ToString()
        #$remotehost
        #$remoteuser
        
        <#$map = New-Object -ComObject WScript.Network        $map.MapNetworkDrive('Z:',$remotehost,$false,$remoteuser,$NewPassword)        if ($map.EnumNetworkDrives() -contains $remotehost) {            $addaccountresults.'Login Result' = "Network login to $Computer was successful."        }        else {            $addaccountresults.'Login Result' = "Network login to $Computer was not successful or an error occured."        }                $map.RemoveNetworkDrive('Z:')#>                $obj = New-Object -TypeName PSObject -Property $addaccountresults        $obj

     }
     catch {
         $ExceptionMessage = $_ | format-list -force | Out-String       "Exception generated for $ComputerName"       $ExceptionMessage 
     }
     

}
else {
  
  "Could not connect to computer $ComputerName ...`r`n" 


}