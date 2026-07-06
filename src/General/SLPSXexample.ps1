# Purpose: SLPSXexample — General-purpose PowerShell utilities.
#https://sqlpsx.codeplex.com/
$SQLDBName = "AdventureWorks"
$Table = 'HumanResources.Employee'
$SqlQuery = "select * FROM $Table"
get-sqldata -sqlserver sql2 -dbname $SQLDBName -qry $SqlQuery