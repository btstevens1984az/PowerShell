# Purpose: CreateObjectFromCSV — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE:
#
# KEYWORDS: ADSI, Abstract, Pattern, csv
#
# COMMENTS: This script creates an object in AD
# Can create a user, comptuer, group, organizationalUnit
# and other objects in AD. 
#
#
# ------------------------------------------------------------------------

$csvPath = "C:\bestpractices\objects.csv"
$csvParams = import-csv -path $csvPath
foreach($csv in $csvParms)
{
$path = $csv.Path
$class = $csv.Class
$name = $csv.Name

$adsi = [adsi]"LDAP://$path"
$de = $adsi.Create($class,$name)
$de.SetInfo()
}