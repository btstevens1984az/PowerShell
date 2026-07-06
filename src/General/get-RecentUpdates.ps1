# Purpose: get-RecentUpdates — General-purpose PowerShell utilities.
$patternProduct = ‘update: (.*)’
$patternKB = ‘KB(\d{5,9})’
(Get-Content C:\Windows\WindowsUpdate.log) -match ‘successfull’ |
ForEach-Object {
$result = 1 | Select-Object -Property Date, KB, Product
if ($_ -match $patternProduct)
{
$result.Product = $matches[1]
}
if ($_ -match $patternKB)
{
$result.KB = $matches[1]
}
$result.Date = [DateTime] ($_.SubString(0,10) + ‘ ‘ + $_.SubString(11, 8))
$result
} | Out-GridView -Title ‘Recently installed updates'
