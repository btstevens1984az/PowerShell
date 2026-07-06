# Purpose: Datediff — General-purpose PowerShell utilities.
#change path
$file = dir ipconfig.txt
$datediff = (get-date) - $file.LastAccessTime
write-host $file.name "has not been used in"$datediff.days "days"

