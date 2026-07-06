# Purpose: LocateDisabledUserAccounts — General-purpose PowerShell utilities.
﻿# -----------------------------------------------------------------------------
# LocateDisabledUserAccounts.ps1
# ed wilson, msft, 10/9/2008
#
# uses the [adsiSearcher] type accelerator
# [adsiSearcher] is system.DirectoryServices.DirectorySearcher .NET framework
# class. When [adsiSearcher] saves creating instance of class, and we can
# cast a string as the filter property of the class. Important: DO NOT have
# a space in the filter: objectClass=user works. BUT objectClass = user does 
# not work. 
#
# -----------------------------------------------------------------------------
 #Requires -Version 2.0
 $filter = "objectClass=user"
 ([adsiSearcher]$filter).findall() | 
 foreach-object `
 { 
    $uac = ([adsi]$_.path).psbase.invokeget("useraccountControl")
    if($uac -band 0x2)
      { 
        write-host -ForegroundColor red `
        "$($_.properties.item("distinguishedName")) is disabled" 
      }
      ELSE
      {
       Write-Host -ForegroundColor green `
       "$($_.properties.item("distinguishedname")) is NOT disabled"
      }
 }