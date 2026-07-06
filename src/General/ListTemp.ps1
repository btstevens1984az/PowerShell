# Purpose: ListTemp — General-purpose PowerShell utilities.
# powershell2
# Kerry Kreitinger
# file management

# PowerShell Temp File Script to List the Temp Files
$KerryTemp = "$Env:temp"
set-location $KerryTemp
$Dir = Get-Childitem $KerryTemp -recurse
$List = $Dir | Where-object {$_.extension -eq ".tmp"}
foreach ($_ in $List ){$_.name
$count = $count +1}
"Number of files " +$count