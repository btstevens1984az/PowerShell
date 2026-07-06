# Purpose: Locate-StreetAddress — General-purpose PowerShell utilities.
# locate-streetaddress.ps1 -address "1 microsoft way, redmond, wa"
param ($address)
if (-not $address) 
{
    "Street address:"
    $address = Read-host
}
$shell = new-object -com wscript.shell
$shell.run("streets.exe")
start-sleep 5
$shell.appactivate("Map - Microsoft Streets & Trips")
start-sleep 1
$shell.sendkeys("$address")
$shell.sendkeys("{ENTER}")




