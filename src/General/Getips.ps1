# Purpose: Getips — General-purpose PowerShell utilities.
#Run as Script ($psscriptRoot)
$IPv4Pattern = "\b(25[0-4]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b"
$results = Select-String -Path "$PsscriptRoot\filterips.txt" -Pattern $IPv4Pattern
$results.matches.value |  select-object -Unique

#one line version with live data
#(ipconfig | Select-String  -Pattern $IPv4Pattern).matches.Value










#v2 - no automatic array member enumeration
#$results | %{$_.matches} | %{$_.value} | select-object -Unique

<#PSH3 option 
    $scriptpath =$PSScriptRoot
    $results.matches.value |  select-object -Unique
    # or
    (ipconfig | Select-String  -Pattern $IPv4Pattern).matches.Value
#>
