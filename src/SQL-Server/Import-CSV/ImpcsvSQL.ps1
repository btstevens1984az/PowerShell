# Purpose: ImpcsvSQL — SQL Server administration and queries.
####################################################################
#	      Date: 07/17/2015
#	      Reviewer:
#	      Desc : Import CSV file to SQL table
#
#####################################################################
########################Load SQL Snapin##############################

If ((Get-PSSnapin | where {$_.Name -match "SqlServerCmdletSnapin100"}) -eq $null)
{
  Add-PSSnapin SqlServerCmdletSnapin100
}

If ((Get-PSSnapin | where {$_.Name -match "SqlServerProviderSnapin100"}) -eq $null)
{
  Add-PSSnapin SqlServerProviderSnapin100
}

$sql_instance_name = 'ServerSQL01\LAB'
$db_name = 'testdb'

$impcsv = ".\Example.csv"

$data = import-csv $impcsv

$count = 1

foreach($i in $data){

$country = $i.country
$name = $i.name
$SAMAccountName = $i.SAMAccountName
$FirstName = $i.FirstName
$Lastname = $i.Lastname 
$UserSamname = $i.UserSamname
$Access = $i.Access

$query = "INSERT INTO testlist (country,name, SAMAccountName, FirstName, Lastname, UserSamname, Access)
             VALUES ('$country','$name','$SAMAccountName','$FirstName','$Lastname','$UserSamname','$Access')"

$impcsv = invoke-sqlcmd -Database $db_name -Query $query  -serverinstance $sql_instance_name 

write-host "Processing row ..........$count" -foregroundcolor green

$count  = $count + 1

}

###################################################################