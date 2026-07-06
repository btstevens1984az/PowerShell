# Purpose: GetRoleFunction — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 12/14/2008
#
# KEYWORDS: .NET framework, security, reference
#
# COMMENTS: This script will detect what role a user
# currently occupies. The allowed roles are listed here:
# Administrator
# User
# Guest
# PowerUser
# AccountOperator
# SystemOperator
# PrintOperator
# BackupOperator
# Replicator
#
# PowerShell Best Practices, chapter 5
# ------------------------------------------------------------------------
Function GetAdmin([ref]$isInRole)
{
 $currentUser = [Security.Principal.WindowsIdentity]::getCurrent()
 $principal = new-object security.Principal.windowsPrincipal($currentUser)
 $role = [security.principal.WindowsBuiltInRole]::$roleName
 $isInRole.value = $principal.IsInRole($role)
 } #end GetAdmin function
 
# *** Entry point to script ***

$isInRole = $null
$roleName = "User"
GetAdmin([ref]$isInRole)
if($isInRole) 
  { "Current console has the $roleName role" }
ELSE
  { "Current console does not have the $roleName role" }