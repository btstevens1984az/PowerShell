# Purpose: add2groupCSV2 — General-purpose PowerShell utilities.
# powershell2
# add2groupCSV.ps1
# read a csv file - pull computer name identity  and query it for samid - csv is at rootof H:\
# use samid to add user to group
# September 2010 Kerry K

$csvname = read-host "Please enter the name for the CSV file you wish to import"
$CSVPath = "h:\" + "$csvname"
$csv = Import-CSV $CSVPath


Foreach($line in $csv)

{ 

$newmember= $line.NAME
write-host .
write-host Computer NAME from CSV file is "(newmember)" $newmember

$addme2group= (dsquery computer -name "$newmember")
 write-host DSQUERY COMPUTER -NAME variable "(addme2group)" $addme2group
 write-host .
dsmod group "CN=ComputersWMI,OU=Security Groups,DC=example,DC=local" -addmbr "$addme2group"
}
