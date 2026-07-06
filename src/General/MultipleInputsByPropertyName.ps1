# Purpose: MultipleInputsByPropertyName — General-purpose PowerShell utilities.
$csv =@"
"Name","Status","ComputerName"
"AdobeARMservice","Running","localhost"
"bits","Stopped","kms"
"netlogon","this doesn't matter","dc2"
"@

$import= $csv | ConvertFrom-Csv

$import | get-service | select-object MachineName,name,status