# Purpose: BulkEdit-AD — General-purpose PowerShell utilities.
﻿$CSVFile = "C:\employeeNumbers.csv"

# Set up a directory searcher
$root = new-object system.directoryservices.directoryentry "LDAP://RootDSE"
$rootDN = "GC:`/`/" + $root.rootDomainNamingContext
$domain = [ADSI] $rootDN
$dsSearcher = New-Object directoryservices.directorySearcher($domain)

#Process the CSV File
$employees = Import-Csv $CSVFile
$employees | foreach-object `
{
	# Filter AD objects by SMTP address
	$employeenumber = $_.employeenumber
	$formalfullname = $_.formalfullname
	$dssearcher.Filter = "(proxyaddresses=smtp:" + $_.email + ")"
	$results = $dssearcher.FindAll()
	if ($results.count -eq 1)
	{
		# Switch from GC to DC
		$UserDN =  $results[0].path.replace("GC://","LDAP://")
		"FOUND: " + $UserDN
		$user = [ADSI] $UserDN
		#$User.employeenumber = $employeenumber
		#$User.SetInfo()
	}
	else
	{
		"ERROR: " + $formalfullname + " - found " + $results.count + " matches"
	}
}
