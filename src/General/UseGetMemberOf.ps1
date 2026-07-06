# Purpose: UseGetMemberOf — General-purpose PowerShell utilities.
﻿# -------------------------------------------------------------------------
# UseGetMemberOf.ps1
# ed wilson, msft, 11/12/2008
#
# -------------------------------------------------------------------------
Function GetMemberOf($group)
{
 $user = [System.Security.Principal.WindowsIdentity]::GetCurrent()
 $nt = "System.Security.Principal.NtAccount" -as [type]
 If( $user.Groups | ForEach-Object { $_.translate($NT) -match "$group"} )
  { 
    if(Test-Path -Path $bogusFile)
       {
         Add-Content -Path $bogusFile -Value "Added bogus content`r`n"
         "Added content to $bogusFile"
         Notepad $bogusFile
       } #end if Test-Path 
    ELSE
       { 
         "Unable to find $bogusFile" 
       } #end else   
  } #end if user
 ELSE
    {
     "$($user.name) is not a member of $group"
    }
} #end GetMemberOf

$bogusFile = "C:\bogus\bogus.txt"
GetMemberOf -group "bogus"