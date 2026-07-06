# Purpose: SQLQuery3 — SQL Server administration and queries.
$database = "AdventureWorks"
$datasource = "syddc01"
$authentication = "Integrated Security=SSPI;"
$commandString = "SELECT TOP 100 [EmployeeID]
      ,[NationalIDNumber]
      ,[ContactID]
      ,[LoginID]
      ,[ManagerID]
      ,[Title]
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
  FROM [AdventureWorks].[HumanResources].[Employee]"
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