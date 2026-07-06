# Purpose: SQLQuery — SQL Server administration and queries.
$database = "AdventureWorks2008"
$datasource = "syddc01"
$authentication = "Integrated Security=SSPI;"
$commandString = "SELECT TOP 1000 [BusinessEntityID]
      ,[NationalIDNumber]
      ,[LoginID]
      ,[OrganizationNode]
      ,[OrganizationLevel]
      ,[JobTitle]
      ,[BirthDate]
      ,[MaritalStatus]
      ,[Gender]
      ,[HireDate]
      ,[SalariedFlag]
      ,[VacationHours]
      ,[SickLeaveHours]
      ,[CurrentFlag]
      ,[rowguid]
      ,[ModifiedDate]
  FROM [AdventureWorks2008].[HumanResources].[Employee]"
$connectionString = "Provider=sqloledb; " +
                    "Data Source=$dataSource; " +
                    "Initial Catalog=$database; " +
                    "$authentication; "

$connection = New-Object System.Data.OleDb.OleDbConnection $connectionString
$connection.open()
$command = New-Object Data.OleDb.OleDbCommand $commandString,$connection
$adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command
$dataset = New-Object System.Data.DataSet
[void] $adapter.Fill($dataSet)
$results = $dataSet.Tables | Select-Object -ExpandProperty Rows
$results