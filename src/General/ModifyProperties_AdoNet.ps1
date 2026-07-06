# Purpose: ModifyProperties AdoNet — General-purpose PowerShell utilities.
Param([switch]$verbose)

Function TestPath($FilePath)
{
 If(Test-Path -path $FilePath)
   {
    Write-Verbose "$filePath found"
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
 $strSheetName = 'NewUser$'
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
 $columns = $Script:DataReader.FieldCount 
 $aryProperties = [array]::CreateInstance([string],$columns)

 $rowNumber = 0
 While($Script:DataReader.read())
 {
  Write-Verbose "Row number is $rowNumber"
  if($rowNumber -eq 0)
   {
    For($i = 0 ; $i -le $columns -1 ; $i ++)
       {
        Write-Verbose "adding property $i"
        Write-verbose $script:DataReader[$i].ToString()
        $aryProperties[$i] = $script:DataReader[$i].ToString()
       } #end for
   } #end if rownumber
   Write-verbose "printing aryProperties: $aryProperties"
  if($rowNumber -ge 1)
    {
     ModifyObject
    }
  $rowNumber ++
 } #end while
} #end ReadData

Function ModifyObject()
{
 $script:path = "$($script:DataReader[0]),$($script:DataReader[1]),$($script:DataReader[2])"
 Write-Verbose  "Modifying $script:path"
 
For($j = 3 ; $j -le $columns -1 ; $j++)
{
 $adsi = [adsi]"LDAP://$Script:path"
 Write-Verbose "Object: $Script:path"
 write-verbose  "Putting: $($aryProperties[$j]),$($Script:DataReader[$j])"
 if( [string]::IsNullOrEmpty($($script:DataReader[$j])) ) 
    { "missing value: $($aryProperties[$j]) for: $script:path" }
 ELSEif( [string]::IsNullOrEmpty($($aryProperties[$j])) ) 
    { "missing property for $($script:DataReader[$j]) value" }
  ELSE
  {
   $adsi.Put($($aryProperties[$j]),$($Script:DataReader[$j]))
   $adsi.SetInfo()
  }
}
} #end ModifyObject

Function CloseAdoConnection()
{  
 $Script:dataReader.close()
 $Script:objConn.close()
}

# *** Entry Point ***
if($verbose) { $verbosePreference = "continue" }
$FilePath = "C:\BestPractices\ModifyUser.xls"
TestPath($FilePath)
SetConnectionString
ReadData
CloseAdoConnection