# Purpose: FindDisabledUserAccounts — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# FindDisabledUserAccounts.ps1
# ed wilson, 3/28/2008
#
# Creates an instance of the DirectoryServices DirectorySearcher .NET 
# Framework class to search Active Directory.
# Creates a filter that is LDAP syntax that gets applied to the searcher
# object. If we only look for class of user, then we also end up with
# computer accounts as they are derived from user class. So we do a 
# compound query to also retrieve person
# We then use the findall method and retrieve all users
# Next we use the properties property and choose item to retrieve the
# distinguished name of each user, and then we use the distinguished name
# to perform a query and retrieve the UAC attribute, and then we do a 
# boolean to compare with the value of 2 which is disabled.
#
# ------------------------------------------------------------------------
#Requires -Version 2.0

$filter = "(&(objectClass=user)(objectCategory=person))"
$users = ([adsiSearcher]$Filter).findall()

 foreach($suser in $users)
  {
   "Testing $($suser.properties.item(""distinguishedname""))"
   $user = [adsi]"LDAP://$($suser.properties.item(""distinguishedname""))"
  
   $uac=$user.psbase.invokeget("useraccountcontrol")
     if($uac -band 0x2) 
       { write-host -foregroundcolor red "`t account is disabled" } 
     ELSE 
       { write-host -foregroundcolor green "`t account is not disabled" }
  } #foreach