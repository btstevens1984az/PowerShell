# Purpose: QueryComputersUseCredentialsFromRegistry — Security auditing and compliance checks.
# ------------------------------------------------------------------------
# DATE: 6/15/2009
#
# KEYWORDS: Registry, Password, Query Active Directory,
# ADO COM
# COMMENTS: This script reads the registry to obtain the 
# password required to perform a query of Active Directory.
#
# PowerShell Best Practices Chapter 12
# ------------------------------------------------------------------------
$strBase = "<LDAP://dc=nwtraders,dc=msft>"
$strFilter = "(objectCategory=computer)"
$strAttributes = "name"
$strScope = "subtree"
$strQuery = "$strBase;$strFilter;$strAttributes;$strScope"
$strUser = "nwtraders\administrator"
$strPwd = (Get-ItemProperty HKCU:\Software\ForScripting\CompatPassword).password

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
