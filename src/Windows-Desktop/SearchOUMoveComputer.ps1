# Purpose: SearchOUMoveComputer — Windows desktop configuration and management.
﻿# -----------------------------------------------------------------------------
# SearchOUMoveComputer.ps1
# ed wilson, msft, 10/9/2008
# 
# Uses [adsiSearcher] type accelerator for DirectoryServices.DirectorySearcher 
# .NET framework class. 
# Uses filter to return computer objects
# Uses searchroot to target particular location
# uses findall method to locate all computers matching the query
# It then uses the moveTo method from the directoryEntry class. 
# 
# -----------------------------------------------------------------------------
#Requires -version 2.0

$filter = "objectCategory=computer"
$destination = "LDAP://ou=mytest,dc=Nwtraders,dc=com"
$ds = [adsiSearcher]$filter
$ds.SearchRoot = "LDAP://ou=dumb,dc=nwtraders,dc=com"
$ds.findAll() |
ForEach-Object `
{
 $de = [adsi]$_.path
 $de.psbase.MoveTo($destination)
}