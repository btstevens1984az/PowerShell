# Purpose: Invoke-SQLCmd — SQL Server administration and queries.
Function Invoke-SQLCmd {$SQLDBName = "AdventureWorks"
$Table = 'HumanResources.Employee'
$SqlQuery = "select * FROM $Table"
Invoke-Sqlcmd -Query $SqlQuery -ServerInstance sql2 -Database $SQLDBName | Out-GridView
}