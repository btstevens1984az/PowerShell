# Purpose: biggestfileswithprogress — Storage management and disk operations.
$begin = Get-date

$count=0
Get-ChildItem c:\windows -ea silentlycontinue -Recurse | ForEach-Object {$_ 
$count +=1
If ($count -gt 1000)
{$count =1}
Write-Progress -Activity "File Checker" -Status "Running" -PercentComplete ($count/1000*100)} -End {Write-Progress -Activity "File Checker" -Status "Complete" -PercentComplete 100}| Sort-Object length -Descending |
select -first 10 | FT name,length

$end = Get-Date
$end-$begin | fl *


<#
This will run significantly faster if you don't put the get-childitem as part of the pipeline:
$begin = Get-date
$files = Get-ChildItem c:\ -ea silentlycontinue -Recurse
$files | Sort-Object length -Descending | select-object -first 10 | Format-Table name,length
$end = Get-Date
$end-$begin | fl *
#>
