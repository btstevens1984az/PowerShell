# Purpose: SqlQuery2 — SQL Server administration and queries.
#***************Modify Here*****************
$SQLServer = "sql2"
#use Server\Instance for named SQL instances!
$SQLDBName = "AdventureWorks"
$Table = 'HumanResources.Employee'
$SqlQuery = "select * FROM $Table"

#***********End Modify Section*****************
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection 
$SqlConnection.ConnectionString = "Server = $SQLServer; Database = $SQLDBName; Integrated Security = True"
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlCmd.CommandText = $SqlQuery
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet)
$datarows = $dataset.tables[0]
$datarows | Out-GridView
<#
$SqlCmd.CommandText = $SqlQuery2
$SqlAdapter.SelectCommand = $SqlCmd
$DataSetNN = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSetNN)
#>
$SqlConnection.Close()

#http://technet.microsoft.com/en-us/magazine/hh289310.aspx 

Function Get-MySQLData
{
#***************Modify Here*****************
param($SQLServer = "sql2",
#use Server\Instance for named SQL instances!
$SQLDBName = "AdventureWorks",
$SqlQuery = "select * FROM 'HumanResources.Employee'")

#***********End Modify Section*****************
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection 
$SqlConnection.ConnectionString = "Server = $SQLServer; Database = $SQLDBName; Integrated Security = True"
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlCmd.CommandText = $SqlQuery
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet)
$datarows = $dataset.tables[0]
$datarows #| Out-GridView
<#
$SqlCmd.CommandText = $SqlQuery2
$SqlAdapter.SelectCommand = $SqlCmd
$DataSetNN = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSetNN)
#>
$SqlConnection.Close()
}