# Purpose: Get-NetworkCapture — Network diagnostics, DNS, DHCP, and connectivity.
Function Get-NetworkCapture{
<#Header - Lex Thomas, Keith Ramphal Net Session Capture in Powershell. Modified by Todd Maxey#>
# Add - Full frame capture by removing -Truncationlength 512
# Add - Wait till ENTER is pressed to stop trace
# Add - ARP cache and Kerberos ticket purge
# Moved - cache and ticket purge to after starting network trace as not to miss the traffic
# Add Hit "ENTER" to start and stop trace
# Add Elevated permission check
# Removed tracing FOR loop
# Add code to remove any previous NetEventSessions
#
Write-Host ""
Write-Host "Checking for elevated permissions..." -ForegroundColor Yellow
Write-Host ""
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
[Security.Principal.WindowsBuiltInRole] "Administrator")) {
Write-Host "Insufficient permissions to run this script. Open the PowerShell console as an administrator and run this script again." -ForegroundColor Red
Write-Host ""
Break
}
else {
Write-Host ""
Write-Host "Code is running as administrator — go on executing the script..." -ForegroundColor Green
Write-Host ""
}
$path = "C:\temp\capture\"
If(!(test-path $path))
{
  New-Item -ItemType Directory -Force -Path $path
}
#Remove any previous NetEventCapture sessions
Stop-NetEventSession -name NetCap42 -ErrorAction SilentlyContinue
Remove-NetEventSession -Name NetCap42 -ErrorAction SilentlyContinue

#this next line will gather computername as well as the time and format it with the following Computername Day-24hr Minute (This is at the START of the capture session)
Write-Host ""
Write-Host "Creating capture session" -ForegroundColor Yellow
New-NetEventSession -Name NetCap42 -LocalFilePath c:\temp\Capture\$env:computername" "$(get-date -f dddd-MMMM-dd-yyyy-HH.mm.ss).etl
Add-NetEventPacketCaptureProvider -SessionName NetCap42 -Truncationlength 65535
Start-NetEventSession -Name NetCap42

#Flush all resolver caches
Write-Host ""
Write-Host "Flushing DNS, NetBIOS, ARP and Kerberos caches" -ForegroundColor Yellow
ipconfig /Flushdns
Arp -d *
Nbtstat -RR

#flush kerberos tickets for user and machine
Klist purge
klist -li 0x3e7 purge  #machine

Write-Host ""
Write-Host “Press ENTER start capture session” -ForegroundColor Yellow

Read-Host " "
Write-host "Please reproduce issue NOW." -ForegroundColor Green
Write-Host ""
Write-Host “Press ENTER to stop capture session when reproduction is complete” -ForegroundColor Yellow
Read-Host " "
Write-Host "Retrive your ETL trace file @ $path"  -ForegroundColor Yellow
Write-Host "Opening Explorer to $path"  -ForegroundColor Yellow
Stop-NetEventSession -name NetCap42
Remove-NetEventSession -name NetCap42 
Start-sleep -s 5

#Open file Explorer to capture location
explorer $path

Exit
}