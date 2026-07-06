# Purpose: QueryComputersUseCredentialsFromText — Security auditing and compliance checks.
$strBase = "<LDAP://dc=nwtraders,dc=msft>"
$strFilter = "(objectCategory=computer)"
$strAttributes = "name"
$strScope = "subtree"
$strQuery = "$strBase;$strFilter;$strAttributes;$strScope"
$strUser = "Nwtraders\LondonAdmin"
$strPwd = Get-Content �path "C:\fso\password.txt"

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
