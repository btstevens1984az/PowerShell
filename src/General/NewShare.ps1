<#
.SYNOPSIS
Creates a new SMB share and sets initial share permissions
.DESCRIPTION
Creates a new SMB share and sets initial permissions. This version is limited to setting permissions for a single user or group.
.PARAMETER name
Name of share
.PARAMETER path
local share file path
.PARAMETER computer
Server to create the share on
.PARAMETER description
Share description
.PARAMETER account
Account to grant share permissions to
.PARAMETER rights
The fights to grant the account. Examples are Read,FullControl,write
.PARAMETER maxallowed
Max connections allowed, not typically used
.EXAMPLE
PS C:\> import-csv C:\Users\administrator\Desktop\CreateShares.csv | New-share
Create shares using CSV input.
NAME        :  New-Share
LAST UPDATED:  2/27/2015
modified from: https://gallery.technet.microsoft.com/scriptcenter/Create-a-Share-and-Set-eb177a79
.INPUTS
None
.OUTPUTS
None
#>
function New-share{

[CmdLetBinding()] 
param(
    [parameter(Mandatory=$true,
               ValueFromPipelineByPropertyName=$true)]
    [alias("ShareName")]
    [string]$name,
    [parameter(Mandatory=$true,
               ValueFromPipelineByPropertyName=$true)] 
    [string]$path,
    [parameter(Mandatory=$true,
               ValueFromPipelineByPropertyName=$true)]
    [Alias("server")]  
    [string]$computer=$env:COMPUTERNAME, 
    [string]$description = "",
    [parameter(ValueFromPipelineByPropertyName=$true)]  
    [System.Security.Principal.NTAccount]$account="$($env:userdomain)\$($env:username)",
    [parameter(ValueFromPipelineByPropertyName=$true)]  
    [System.Security.AccessControl.FileSystemRights]$rights='Read', 
    [string]$maxallowed = $null 
) 

process {
    if ($env:COMPUTERNAME -eq $computer) #local server
        {
            if (-not (Test-Path $path))
            {
                mkdir $path -Force
            }
        }
    else #remoteServer
    {
        $remotepath = Convert-ToSMBPath -localpath $path -Server $computer
        If (-not(Test-Path $remotepath))
        {
            mkdir $remotepath -Force
        }
    }

    Write-Verbose "Using WMI to create a new Security Descriptor" 
    $sd = ([WMIClass] "Win32_SecurityDescriptor").CreateInstance() 
 
    Write-Verbose "Create new ACE" 
    $ace=Create-WMIAce $account $rights 
 
    Write-Verbose "Add Ace to DACL" 
    $sd.DACL += @($ace.psobject.baseobject) # append 
    $sd.ControlFlags="0x4" # set SE_DACL_PRESENT flag  
 
    $share = [wmiclass]"\\$computer\root\CimV2:Win32_Share" 
    Write-Verbose 'Calling WMI to Create share.' 
    $result=$share.Create( $path, $name, 0, $maxallowed,$description,$null,$sd ) 
    if($result.returnValue -ne 0){ 
         Write-Host "Create share failed with returnValue=$($result.returnValue)" -ForegroundColor red -BackgroundColor white 
         return  
    } 
}
}

function Create-WMITrustee([string]$NTAccount){ 
 
    $user = New-Object System.Security.Principal.NTAccount($NTAccount) 
    $strSID = $user.Translate([System.Security.Principal.SecurityIdentifier]) 
    $sid = New-Object security.principal.securityidentifier($strSID)  
    [byte[]]$ba = ,0 * $sid.BinaryLength      
    [void]$sid.GetBinaryForm($ba,0)  
     
    $Trustee = ([WMIClass] "Win32_Trustee").CreateInstance()  
    $Trustee.SID = $ba 
    $Trustee 
     
} 
Function Convert-ToSMBPath
{
    [CmdLetBinding()]
    param (
        [parameter(Mandatory=$true,
               ValueFromPipelineByPropertyName=$true,
               ValueFromPipeline=$true
               )]
        [string]$localpath,
        [parameter(Mandatory=$true,
               ValueFromPipelineByPropertyName=$true)]
        [string]$Server
        )
    process
    {
        $pathParts = $localpath -split ":"
        $driveLetter = $pathParts[0]
        $sharePath = $pathParts[1]
        $NewSharePath = "\\$server\$driveLetter`$$sharePath"
        $NewSharePath
    }
}
 
function Create-WMIAce{ 
     param( 
          [string]$account, 
          [System.Security.AccessControl.FileSystemRights]$rights 
     ) 
    $trustee = Create-WMITrustee $account 
    $ace = ([WMIClass] "Win32_ace").CreateInstance()  
    $ace.AccessMask = $rights  
    $ace.AceFlags = 0 # set inheritances and propagation flags 
    $ace.AceType = 0 # set SystemAudit  
    $ace.Trustee = $trustee  
    $ace 
} 

