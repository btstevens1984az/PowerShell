# Purpose: MISC-Patching — Windows Update and patch management.
$serverArray = "SERVER HERE"
Clear-Host

$date = Get-Date

Write-Host "Terminal Server Health Check - $date" 
"`r`n"

foreach($computer in $serverArray){
    if(!(Test-Connection $computer -Count 2 -Quiet)) {
       Write-Host "$computer is offline" -ForegroundColor White -BackgroundColor Red
    }
    else {
        Write-Host "$computer is online" -ForegroundColor White -BackgroundColor DarkGreen
        }

}

"`r`n"



Write-Host "Window will close in 60 seconds"
Start-Sleep -S 60

$timeSec = 60
do {
    Write-Host $timeSec
    Start-Sleep 1
    $i--
} while ($i -gt 0)