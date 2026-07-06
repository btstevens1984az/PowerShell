# Purpose: CreateObject AdoNet — General-purpose PowerShell utilities.
Param([switch]$verbose)

Function TestPath($FilePath)
{
 If(Test-Path -path $FilePath)
   {
    if($verbose) { "$filePath found" }
  } #end if
 ELSE
  {
   Write-Host -foregroundcolor red "$filePath not found."
   Exit
  } #end else
} #end TestPath

Function SetConnectionString()
{
 $strFileName = $FilePath
 $strSheetName = 'Excel$'
 $strProvider = "Provider=Microsoft.Jet.OLEDB.4.0"
 $strDataSource = "Data Source = $strFileName"
 $strExtend = "Extended Properties=Excel 8.0"
 $strQuery = "Select * from [$strSheetName]"
 NewAdoConnection
} #end SetConnectionString

Function NewAdoConnection()
{
 $Script:objConn = New-Object System.Data.OleDb.OleDbConnection("$strProvider;$strDataSource;$strExtend")
 $sqlCommand = New-Object System.Data.OleDb.OleDbCommand($strQuery)
 $sqlCommand.Connection = $objConn
 $Script:objConn.open()
 $Script:DataReader = $sqlCommand.ExecuteReader()
} #end NewAdoConnection

Function ReadData()
{
 While($Script:DataReader.read())
 {
  $Script:Name = $Script:DataReader[0].Tostring() 
  $Script:Path = $Script:DataReader[1].Tostring() 
  $Script:Class = $Script:DataReader[2].Tostring() 
  CreateObject
 } #end while
} #end ReadData

Function CreateObject()
{
 If($verbose)
  {
   "Creating $Script:Class $Script:Name,$Script:Path"
  } #end if verbose
 $adsi = [adsi]"LDAP://$Script:path"
 $de = $adsi.Create($Script:class,$Script:name)
 $de.SetInfo()
} #end CreateObject

Function CloseAdoConnection()
{  
 $Script:dataReader.close()
 $Script:objConn.close()
}

# *** Entry Point ***
$FilePath = "C:\BestPractices\excel.xls"
TestPath($FilePath)
SetConnectionString
ReadData
CloseAdoConnection
