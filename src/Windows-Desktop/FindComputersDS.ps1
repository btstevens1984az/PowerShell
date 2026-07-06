# Purpose: FindComputersDS — Windows desktop configuration and management.
﻿# -----------------------------------------------------------------------------
# FindComputersDS.ps1
# ed wilson, msft, 10/9/2008
#
# Uses the System.DirectoryServices.DirectorySearcher .net framework object
# SearchRoot property is used to designate starting point for search
# Filter property is the filter
# findall finds all instances of the object
#
# -----------------------------------------------------------------------------
$SearchRoot = "ou=mytest,dc=nwtraders,dc=com"
$Filter = "objectcategory=computer"
$ds = New-Object -TypeName System.DirectoryServices.DirectorySearcher
$ds.SearchRoot = "LDAP://$SearchRoot"
$ds.Filter = $filter
$ds.FindAll()