# Purpose: XpathETLlogQuery — General-purpose PowerShell utilities.
$day = 86400000
$time = (Get-Date "11/16/2011 14:02:00")
[int]$timespan = ((Get-Date)-$time).TotalMilliseconds
#$events =get-winevent -LogName "Windows Powershell" -FilterXPath "*[System[EventID=600 and TimeCreated[timediff(@SystemTime) <= 86400000]]]"

$events = Get-WinEvent -Path c:\Temp\trace.etl -oldest -FilterXPath "*[System[TimeCreated[timediff(@SystemTime) <= $timespan]]]"