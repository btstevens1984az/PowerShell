# Purpose: HashvsArrayperformance — PowerShell automation.
$adusers = Get-ADUser -Filter *
$aduserhash = $adusers | Group-Object -Property name -AsHashTable
Measure-Command {$adusers.name -contains "jeff"}
Measure-Command {$aduserhash.ContainsKey("jeff")}

$files = dir C:\windows -Recurse -File -ErrorAction SilentlyContinue
$files2 = $files[0..50000]
$fileshash = $files2 | Group-Object -Property fullname -AsHashTable
Measure-Command {$files2.fullname -contains "c:\windows\DFSRadmin.exe"}
Measure-Command {$fileshash.ContainsKey("c:\windows\DFSRadmin.exe")}