# Purpose: add2groupCSV — General-purpose PowerShell utilities.
# powershell2
# add2groupCSV.ps1
# read a csv file - pull user identity (loginname) and query it for samid - csv is at rootof H:\
# use samid to add user to group
# September 2010 Kerry K

$csvname = read-host "Please enter the name for the CSV file you wish to import"
$CSVPath = "h:\" + "$csvname"
$csv = Import-CSV $CSVPath


Foreach($line in $csv)

{ 

$newmember= $line.NAME
write-host .
write-host VALUE of NAME from CSV file is "(newmember)" $newmember

# $addme2group= (dsquery user -samid "$newmember")
# write-host Value of NAME samid variable "(addme2group)" $addme2group
# write-host .
dsquery group -samid ComputersWMI | dsmod group -addmbr "$newmember"

}
