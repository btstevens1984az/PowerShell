# Purpose: WS-KickDisc — General-purpose PowerShell utilities.



$server = Read-Host 
$session = query.exe user /server:server

foreach ($line in $session) {
    $line = -split $line
    if ($line.length -eq 8) {
        
    }
}