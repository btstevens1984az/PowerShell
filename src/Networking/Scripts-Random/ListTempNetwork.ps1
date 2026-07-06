# Purpose: ListNetworkFiles — Network diagnostics, DNS, DHCP, and connectivity.
# powershell2
# Kerry Kreitinger
# file management

# Script to List the Files on a network share
$strPathFiles = "\\222.242.77.61\USERS\"

set-location $strPathFiles
$Dir = Get-Childitem $strPathFiles -recurse
$List = $Dir | Where-object {$_.extension -eq ".exe"}
foreach ($_ in $List ){$_.name
$count = $count +1}
"Number of files " +$count

