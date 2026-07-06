# Purpose: QueryComputersPromptForPassword — Security auditing and compliance checks.
# ------------------------------------------------------------------------
# DATE: 6/15/2009
#
# KEYWORDS: ADO, Active Directory, password
#
# COMMENTS: This script uses the Read-Host cmdlet
# to prompt for a password. It then uses that password
# to retrieve computers from Active Directory.
#
# PowerShell Best Practices ch. 12
# ------------------------------------------------------------------------
$strBase = "<LDAP://dc=nwtraders,dc=com>"
$strFilter = "(objectCategory=computer)"
$strAttributes = "name"
$strScope = "subtree"
$strQuery = "$strBase;$strFilter;$strAttributes;$strScope"
$strUser = "nwtraders\administrator"
$strPwd = Read-Host -prompt "Enter password to Connect to AD"

$objConnection = New-Object -comObject "ADODB.Connection"
$objConnection.provider = "ADsDSOObject"
$objConnection.properties.item("user ID") = $strUser
$objConnection.properties.item("Password") = $strPwd
$objConnection.open("modifiedConnection")
$objCommand = New-Object -comObject "ADODB.Command"

$objCommand.ActiveConnection = $objConnection
$objCommand.CommandText = $strQuery
$objRecordSet = $objCommand.Execute()

Do
{
    $objRecordSet.Fields.item("name") |Select-Object Name,Value 
    $objRecordSet.MoveNext()
}
Until ($objRecordSet.eof) 

$objConnection.Close()
