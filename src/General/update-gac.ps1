# Purpose: update-gac — General-purpose PowerShell utilities.
#http://blogs.msdn.com/powershell/archive/2007/11/08/update-gac-ps1.aspx
Set-Alias ngen @(
dir (join-path ${env:\windir} "Microsoft.NET\Framework") ngen.exe -recurse |
sort -descending lastwritetime
)[0].fullName
[appdomain]::currentdomain.getassemblies() | %{ngen $_.location}