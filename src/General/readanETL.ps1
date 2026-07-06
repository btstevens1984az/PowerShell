# Purpose: readanETL — General-purpose PowerShell utilities.
$events = Get-winevent -Path c:\sample.etl -Oldest -MaxEvents 5000000000 | ?{$_.message}
$events | select *,@{l="expandedvalues";e={($_.properties|%{$_.value}) -join ";"}} | Out-GridView