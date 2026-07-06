# Purpose: InvokeSQLCmd — Core infrastructure automation scripts.
$SQLDBName = "AdventureWorks"
$Table = 'HumanResources.Employee'
$SqlQuery = "select * FROM $Table"
Invoke-Sqlcmd -Query $SqlQuery -ServerInstance sql2 -Database $SQLDBName | Out-GridView