# Purpose: QueryComputersComADO — System monitoring and alerting.
$strBase = "<LDAP://dc=nwtraders,dc=com>"
$strFilter = "(objectCategory=computer)"
$strAttributes = "name"
$strScope = "subtree"
$strQuery = "$strBase;$strFilter;$strAttributes;$strScope"

$objConnection = New-Object -ComObject "ADODB.Connection"
$objCommand = New-Object -ComObject "ADODB.Command"
$objConnection.Open("Provider=ADsDSOObject;")
$objCommand.ActiveConnection = $objConnection
$objCommand.CommandText = $strQuery
$objRecordSet = $objCommand.Execute()

Do
{
    $objRecordSet.Fields.item("name").Value 
    $objRecordSet.MoveNext()
}
Until ($objRecordSet.eof) 

$objConnection.Close()
