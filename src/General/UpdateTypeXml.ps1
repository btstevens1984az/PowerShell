# Purpose: UpdateTypeXml — General-purpose PowerShell utilities.
$array = 1..5
Update-TypeData .\SumArray.ps1xml
Get-Member -InputObject $array
$array.Sum()