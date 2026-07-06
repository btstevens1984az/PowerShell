# ACEMODULE.PS1
# a script file containing custom functions that are useful
#
set-PSdebug -STRICT

function New-RegistryACE {
<#
  .SYNOPSIS
     Create a Registry ACE rule
  .DESCRIPTION
     Take the tedium out of creating the rule, so that you can use it in GET/SET-ACL.
  .EXAMPLE
     New-RegistryACE -NTaccount CONTOSO\USER1 -RegistryRight FullControl -AccessType Allow 
  .PARAMETER NTaccount
     The domain\user of the user who this rule applies to.
  .PARAMETER RegistryRight
     Can have one of the following values:
     QueryValues,SetValue,CreateSubKey,EnumerateSubKeys,Notify,CreateLink,Delete,
     ReadPermissions,WriteKey,ReadKey,ChangePermissions,TakeOwnership,FullControl
  .PARAMETER AccessType
     Can have one of the following values:
     Allow, Deny
#>
 PARAM ([parameter(Mandatory=$true)] [string] $NTaccount, 
        [parameter(Mandatory=$true)] [string] $RegistryRight,
        [parameter(Mandatory=$true)] [string] $AccessType)

  # define the 3 pieces of information needed to create a new RegistryAccessRule object
  if ($NTaccount -eq $NULL) { write-host "NTaccount cannot be null."; return }
  # should do real validation of the NTaccount too...

  $Identity = new-object System.Security.Principal.NTAccount($NTaccount)
  $Right    = [System.Security.AccessControl.RegistryRights]::$RegistryRight
  $Access   = [System.Security.AccessControl.AccessControlType]::$AccessType

  if ($Right -eq $NULL) {
   write-host "invalid RegistryRight specified. Must be one of the following:"
   [enum]::GetValues([System.Security.AccessControl.RegistryRights])
   return
  }
  if ($Access -eq $NULL) {
   write-host "invalid AccessType specified.  Must be one of the following:"
   [enum]::GetValues([System.Security.AccessControl.AccessControlType])
   return
  }

  # create the RegistryAccessRule (ACE) object
  New-Object System.Security.AccessControl.RegistryAccessRule($Identity,$Right,$Access)
}


# if/when we change this script to a module, we can/should also be explicit about what to export and make Public.
# for example we might have some helper-functions that should not be made visible to the users.
# Export-ModuleMember -Function New-*
