# Purpose: GetDataSet — General-purpose PowerShell utilities.
﻿#=================================================================================================
# DATE    : 13/5/2010
# Version : 1.0
# COMMENT : Connect to an ODBC database and retrieve a data set
#   Partially based on concepts from the following resources:
#       PowerShell: How to connect to a remote SQL database and retrieve a data set
#           http://www.systemcentercentral.com/BlogDetails/tabid/143/indexid/60012/Default.aspx
#       Hey, Scripting Guy! How can I use Windows PowerShell to pull records from a Microsoft Access database?
#           http://blogs.technet.com/heyscriptingguy/archive/2006/10/02/how-can-i-use-windows-powershell-to-pull-records-from-a-microsoft-access-database.aspx
# DEBUG MODE : $erroractionpreference = "Inquire"; "`$error = $error[0]"
$myName = $MyInvocation.MyCommand.Name
$myPath = & split-path $myName
set-location $myPath

$outputFile = "DataSet.csv"; # For testing purposes, I'm writing to a CSV file
$record = @{}; # Hash table of returned record names and values
$adOpenStatic = 3
$adLockOptimistic = 3

$now = get-date -format g
"$now # Starting $myName"

$objConnection = New-Object -comobject ADODB.Connection
$objRecordset  = New-Object -comobject ADODB.Recordset

# Construct SQL query
$SqlQuery = "SELECT HD.""Case ID+"", HD.Status, HD.Priority, HD.Summary, HD.""Assigned To Group+"", HD.Category, HD.Type, HD.Item, HD.""Create Time"", HD.Office FROM ""HPD:HelpDesk"" HD WHERE (HD.Source='iWave') AND (HD.""Create Time"">={ts '2010-05-15 00:00:00'})";

Write-Output "Querying database for SCOM generated tickets" # Status update

# The following $objConnection connection string is ODBC driver specific. Customize as needed.
$objConnection.Open("DSN=[YOUR DATA SOURCE NAME];[DSNProprety1Name]=[DSNProperty1Value]; ")

# Now that we've got an open connection, use $SqlQuery to fetch the recordset we want
$objRecordset.Open( $SqlQuery, $objConnection, $adOpenStatic, $adLockOptimistic )

$objRecordset.MoveFirst()

$recordCount = $objRecordset.RecordCount
Write-Output "Found $recordCount unique records";
"";
Write-Output "Writing results to $outputFile";
Write-Output "Ticket ID, Status, Priority, Summary, Assignee Group, Category, Type, Item, Create Time, Office" > $outputFile

do {
    # Join all the items we asked for in the $SqlQuery into an array, to make it easier to print them out to one row
    $recordSetRow = $objRecordset.Fields.Item("Case ID+").Value, $objRecordset.Fields.Item("Status").Value, $objRecordset.Fields.Item("Priority").Value, $objRecordset.Fields.Item("Summary").Value, $objRecordset.Fields.Item("Assigned To Group+").Value, $objRecordset.Fields.Item("Category").Value, $objRecordset.Fields.Item("Type").Value, $objRecordset.Fields.Item("Item").Value, $objRecordset.Fields.Item("Create Time").Value, $objRecordset.Fields.Item("Office").Value
    # Print out the record/row results using the -join operator
    $recordSetRow -join "," > $outputFile
    $objRecordset.MoveNext()
} until ($objRecordset.EOF -eq $True)

$objRecordset.Close()
$objConnection.Close()

