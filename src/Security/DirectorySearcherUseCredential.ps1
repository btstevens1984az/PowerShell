# Purpose: DirectorySearcherUseCredential — Security auditing and compliance checks.
# ------------------------------------------------------------
# DirectorySearcherUseCredential.ps1
# Ed Wilson, msft
# 6/15/2009
# This script uses read-host to obtain password
# it passes this password to the DirectorySearcher
# object via the directoryEntry class. 
# The password is a secure password and is
# not passed in clear text accross the network.
# -------------------------------------------------------------
$de = [adsi]"LDAP://dc=nwtraders,dc=com"
$de.username = "Nwtraders\administrator"
$de.password = Read-Host -prompt "Enter your password" 
$ds = new-object DirectoryServices.DirectorySearcher($de,"objectcategory=computer")
$ds.findone()