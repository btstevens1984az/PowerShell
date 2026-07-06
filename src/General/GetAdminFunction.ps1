# Purpose: GetAdminFunction — General-purpose PowerShell utilities.
﻿# -----------------------------------------------------------------------------
# GetAdminFunction.ps1
# ed wilson, msft, 11/18/2008
# uses Security.Principal.WIndowsIdentity to get the current user object
# uses isinrole method to see if user is in specific role
# 
# -----------------------------------------------------------------------------
Function GetAdmin([ref]$isAdmin)
{
 $currentUser = [Security.Principal.WindowsIdentity]::getCurrent()
 $principal = new-object security.Principal.windowsPrincipal($currentUser)
 $admin = [security.principal.WindowsBuiltInRole]::administrator
 $isAdmin.value = $principal.IsInRole($admin)
 } #end GetAdmin function
 
 $isAdmin = $null
 GetAdmin([ref]$isAdmin)
 if($isAdmin) 
  { "current console has admin rights" }
 ELSE
  { "current console does not have admin rights" }
  
