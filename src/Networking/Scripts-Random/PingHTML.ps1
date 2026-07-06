# Purpose: PingHTML — Network diagnostics, DNS, DHCP, and connectivity.
# PowerShell 2
# Kerry K
# PingHTML.ps1
# Red = #155.49.20.214
# Green = #00FF00
# Blue = #0000FF
# Cyan (blue and green) = #00FFFF
# Magenta (red and blue) = #FF00FF
# Yellow (red and green) = #FFFF00

# <--------------- Start script
clear
$pingResults =("H:\AD-Reports\PingResults.HTM")
$RunDate = (get-date).tostring("MM_dd_yyyy")
$PingTime = (Get-Date -format 'hh:mm')

#Write the preamble of the report
Add-Content -Path $pingResults ("<!DOCTYPE HTML PUBLIC -//W3C//DTD
HTML 4.0//EN http://www.w3.org/TR/REC-html40/strict.dtd>")
Add-Content -Path $pingResults ("<html> <p>")
Add-Content -Path $pingResults ("<head> <p>")
Add-Content -Path $pingResults ("<title> Ping Results </title>")
Add-Content -Path $pingResults ("</head>")
Add-Content -Path $pingResults ("<h3>Report Generated " + $RunDate + "
@ " + $PingTime + "</h3> <p>")


$PingMachines = Gc "H:\AD-Reports\servers.txt"
ForEach($MachineName In $PingMachines)
{$PingStatus = Gwmi Win32_PingStatus -Filter "Address =
'$MachineName'" |
Select-Object StatusCode
If ($PingStatus.StatusCode -eq 0)
{Add-Content -Path $pingResults ("<pre><h3>Server Name: <FONT color =
#00FF00>" + $MachineName + "</FONT></h1></pre><br>")}
Else
{Add-Content -Path $pingResults ("<pre><h3>Server Name: <FONT color =
#155.49.20.214>" + $MachineName + "</FONT></h1></pre><br>")
Add-Content -Path $pingResults ("<p><br>")}
}
