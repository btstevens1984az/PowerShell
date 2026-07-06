# Purpose: WorkWithUserGroups — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------------------------------------------------------
# WorkWithUserGroups.ps1
# ed wilson, msft, 7/4/2008
#
#  *** Requires .NET Framework 3.5 ***
# Loads the System.DirectoryServices.AccountManagement assembly
# Uses the DirectoryServices.AccountManagement.PrincipalContext class
# Uses the DirectoryServices.AccountManagement.UserPrincipal class
# We first create the instance of the principalContext class, and give it
# three values for the constructor: the naming context, the context name, and
# the container name for the context. Next we create a user principal by using
# the find by identity method and give it the context, type of name and the name 
# We then use two methods: getGroups which will give all the direct group
# memberships, but not chase referals. And the getAuthorizationGrops which
# will chase referals, as well as report all security groups that the user is considered
# to be a member of...
# Uses -as [type] to create an alias for a .NET framework class with a long name.
# holds the long string in a variable as well prior to casting to a type.
#
# -----------------------------------------------------------------------------------------------------------------------

function funline($strIN)
{
  "`n$strIN`n$(`"-`" * $strIN.length)"
} #end funline


$dsam = "System.DirectoryServices.AccountManagement" 
[void][reflection.assembly]::LoadWithPartialName($dsam)
$cType = "domain" #context type
$cName = "NWTraders"
$cContainer = "dc=nwtraders,dc=com"

$userName = "myNewUser"
$iType = "SamAccountName"
$dsamUserPrincipal = "$dsam.userPrincipal" -as [type]

$principalContext = new-object "$dsam.PrincipalContext"($cType,$cName,$cContainer)
$userPrincipal = $dsamUserPrincipal::FindByIdentity($principalContext,$iType,$userName)

funline("Direct Group MemberShip:")
$userPrincipal.getGroups() | foreach-object { $_.name }

funline("Indirect Group Membership:")
$userPrincipal.GetAuthorizationGroups()  | foreach-object { $_.name }