# Purpose: Start EnableAuto SCOM — System Center Operations Manager monitoring.

write-Host "This script Starts the SCOM Service (if it is present) and sets it to Automatic in Startup on remote server(s)."
$Temp = Read-Host "Either enter a single server name or the name of a TXT file with a list of servers (No .TXT extension needed)"
$FileIn = $Temp+".TXT"

Write-Host $FileIn

$servers = $Temp

if (Test-Path $FileIn) {
  $servers = Get-Content $FileIn
  }


# setup the error logfile path
# change path to your preferred location for the error logs
$serverserrorlog = "C:\Scripts\reboot\Log\Reboot$($date)error.log"

$servers | ForEach-Object -process {
	# reassign the $_ varible to an easier to read variable for the rest of the script
	$server = $_

		# This is where the code that does the work is to go

		Write-Host "*************"
		Write-Host $Server
		
		Get-Service -computername $Server -name healthservice | Set-Service -StartupType Automatic -Passthru | Start-Service
		Get-WMIObject win32_service -filter "name = 'HealthService'" -computername $Server

}

Write-Host""
write-Host "Press Any key to continue..."

$HOST.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
$HOST.UI.RawUI.Flushinputbuffer()

