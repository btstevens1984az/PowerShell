# Purpose: QueryComputersNETAdo — Windows desktop configuration and management.
Function SetConnectionString()
{
 $strBase = "<LDAP://dc=nwtraders,dc=com>"
 $strFilter = "(objectCategory=computer)"
 $strAttributes = "name"
 $strScope = "subtree"
 $strQuery = "$strBase;$strFilter;$strAttributes;$strScope"
 $strProvider = "Provider=ADsDSOObject"
 NewAdoConnection
} #end SetConnectionString

Function NewAdoConnection()
{
 $Script:objConn = New-Object System.Data.OleDb.OleDbConnection("$strProvider")
 $sqlCommand = New-Object System.Data.OleDb.OleDbCommand($strQuery)
 $sqlCommand.Connection = $objConn
 $Script:objConn.open()
 $Script:DataReader = $sqlCommand.ExecuteReader()
} #end NewAdoConnection

Function ReadData()
{
 While($Script:DataReader.read())
 {
  $Script:DataReader[0].ToString() 
 } #end while
} #end ReadData

Function CloseAdoConnection()
{  
 $Script:dataReader.close()
 $Script:objConn.close()
}

# *** Entry Point ***

SetConnectionString
ReadData
CloseAdoConnection
