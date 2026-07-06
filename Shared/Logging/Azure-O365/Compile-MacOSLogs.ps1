# Purpose: Compile-MacOSLogs — Cross-cutting logging, error handling, and utilities.
$source=("/Library/Logs/","/var/log/","")
$destinationrootfolder="/Users/btstevens1984/Documents/LogFilesCompiles"
$findlogsafter=[datetime]"10/27/2020 01:00:00 AM"
$findloglastdate=[datetime]"11/28/2020 01:59:00 PM"
$numberofsourcefolders=($source.Length - 1)
$count=0
while ($count -lt $numberofsourcefolders) {
$folders=$source[$count].Split('/')
$val=$folders.length
$destinationsubfolder=$folders[$val-1]
$dest= $destinationrootfolder + '/' + $destinationsubfolder
"Creating New Subfolder in the destination Path"
mkdir $dest
$filestocopy=Get-ChildItem -Path $source[$count] -Filter '*.log' -Recurse | where {$_.LastWriteTime -gt $findlogsafter -AND $_.LastWriteTime -lt $findloglastdate}
$len=$filestocopy.Length
"Number of Files to be copied"
$len
$i=0
while ($i -lt $len) {
cd $source[$count]
Copy-Item -Path $filestocopy[$i] -Destination $dest
$i=$i+1
 }
$count++
}