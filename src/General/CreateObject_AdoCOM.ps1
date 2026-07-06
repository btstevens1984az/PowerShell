# Purpose: CreateObject AdoCOM — General-purpose PowerShell utilities.
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
 $Script:objConn = New-Object -comObject "ADODB.Connection"
 $Command = New-Object -comObject "ADODB.Command"
 $Script:objConn.open("$strProvider;$strDataSource;$strExtend")
 $Command.ActiveConnection = $script:objConn
 $Command.Commandtext = $strQuery
 $Script:RecordSet = $Command.Execute()
} #end NewAdoConnection

Function ReadData()
{
 $Script:RecordSet.MoveFirst()
 Do
 {
  $Script:Name = $Script:RecordSet.Fields.Item("name").Value 
  $Script:Path = $Script:RecordSet.Fields.Item("path").Value
  $Script:Class = $Script:RecordSet.Fields.Item("class").Value
  CreateObject
  $Script:RecordSet.MoveNext()
 }
 Until($Script:recordSet.eof)
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
 $Script:recordSet.close()
 $Script:objConn.close()
}

# *** Entry Point ***
$FilePath = "C:\BestPractices\excel.xls"
TestPath($FilePath)
SetConnectionString
ReadData
CloseAdoConnection
