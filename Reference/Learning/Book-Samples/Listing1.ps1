# Purpose: Listing1 — Certification notes and learning materials.
##setup data source
$dataSource = "localhost"         	##SQL instance name
$database = "DBAMonitoring"   	  	##Database name
$sqlCommand = "exec usp_MyReport" 	##The T-SQL command to execute
$TableHeader = "My SQL Report"    	##The title of the HTML page
$OutputFile = "C:\MyReport.htm"   	##The file location

##set HTML formatting
$a = @"
<style>
BODY{background-color:white;}
TABLE{border-width: 1px;
  border-style: solid;
  border-color: black;
  border-collapse: collapse;
}
TH{border-width: 1px;
  padding: 0px;
  border-style: solid;
  border-color: black;
  background-color:#C0C0C0
}
TD{border-width: 1px;
  padding: 0px;
  border-style: solid;
  border-color: black;
  background-color:white
}
</style>
"@

$body = @"
<p style="font-size:25px;family:calibri;color:#ff9100">
$TableHeader
</p>
"@

##Create a string variable with all our connection details 
$connectionDetails = "Provider=sqloledb; " +
                    "Data Source=$dataSource; " +
                    "Initial Catalog=$database; " +
                    "Integrated Security=SSPI;"
 
##Connect to the data source using the connection details and T-SQL command we provided above, and open the connection
$connection = New-Object System.Data.OleDb.OleDbConnection $connectionDetails
$command = New-Object System.Data.OleDb.OleDbCommand $sqlCommand,$connection
$connection.Open()
 
##Get the results of our command into a DataSet object, and close the connection
$dataAdapter = New-Object System.Data.OleDb.OleDbDataAdapter $command
$dataSet = New-Object System.Data.DataSet
$dataAdapter.Fill($dataSet)
$connection.Close()
 
##Return all of the rows and pipe it into the ConvertTo-HTML cmdlet, and then pipe that into our output file
$dataSet.Tables | Select-Object -Expand Rows |
ConvertTo-HTML -head $a �body $body |
Out-File $OutputFile

