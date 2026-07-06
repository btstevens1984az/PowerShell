###########################################################################
#
# Updated by Brandon Stevens
#
###########################################################################
<#
.SYNOPSIS
    Check a file location for acl's containing a group name
.DESCRIPTION
    Just log if an acl is present for the group I'm searching for
.EXAMPLE
    .\Check-ACL.ps1
    You could add code to the ACL not found section but I wanted to keep it basic to help others follow.
#>
Import-Module ActiveDirectory
# $DirectoryList to your network location ie  $DirectoryList = "\\230.220.45.44\GroupDrives"
$DirectoryList = "\\46.124.38.189\CENTACCT" # Build the list
Set-Location $DirectoryList

# Change $GroupID to your add group ie  $GroupID = "ADHelpDesk"
$GroupID = "GroupIDName"

# Change you log location if you don't want to fill up the root of your drive ;o)
$Path = "c:\temp\"
$ProgessLog = "Check-ACL.txt"
$ErrorLog = "Check-ACLError.txt"

#Logging function
Function Log-Message(){
    Param($Message = ".")
    Write-Verbose $Message
    Write-Output $Message | Out-File "$Path$ProgessLog" -Append -Force
}
#Error trap
trap [Exception] {
    $MyInvocation.InvocationName
    Log-Message $($MyInvocation.InvocationName + " Error: " + $_.Exception.GetType().FullName);
    Log-Message $($MyInvocation.InvocationName + " Error: " + $_.Exception.Message); 
    continue;
}
$Folders = Get-ChildItem $DirectoryList -Recurse | where {$_.Attributes -eq 'Directory'} | % {$_.FullName}
ForEach ($Folder in $Folders) {
      If (((Get-Acl $Folder).access | ForEach {$_.IdentityReference}) -match $GroupID){
            Log-Message "$($Folder) - ACL found for $($GroupID)"
        }
}
