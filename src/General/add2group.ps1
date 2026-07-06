# Purpose: add2group — General-purpose PowerShell utilities.
# powershell2
# add2group.ps1
# read a csv file - pull user identity (loginname) and query it for samid
# use samid to add user to group
# September 2010 Kerry K
# read host will prompt user to enter a file name .... ie  UsersToBeMigratedACI.CSV
# edit path to change where the fileis read from

$csvname = read-host "Please enter the name for the CSV file you wish to import"
$CSVPath = "\\149.139.48.115\NTEAMInstalls\222.205.193.149 MIGRATION FILES\Scripts\" + "$csvname"
$csv = Import-CSV $CSVPath


Foreach($line in $csv)

{ 

$newmember= $line.userid
write-host .
write-host VALUE of USERID from CSV file is "(newmember)" $newmember

$addme2group= (dsquery user -samid "$newmember")
write-host Value of UserId samid variable "(addme2group)" $addme2group
write-host .
dsquery group -samid OutlookMigration | dsmod group -addmbr "$addme2group"

}
