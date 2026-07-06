# Purpose: MISC-PaexecFromTxt — General-purpose PowerShell utilities.
#   James Wylde

#----------------------------------------------------------------------------------------#
#   Modules

# remove "is offline for easy cleanup"
# find and replace firewall return text


Get-ADGroupMember "GBR-WS-DirectAccess" | Select-Object name | Export-Csv -path C:\temp\export.csv
Rename-Item -Path c:\temp\export.csv -NewName "computers.txt"

Clear-Host

Start-Transcript -Path "c:\temp\EXPORT-DONOTDELETE.txt" -NoClobber
foreach($computer in Get-Content -Path c:\temp\computers(sweep2).txt){
    if(!(Test-Connection $computer -Count 1 -Quiet)) {
       "$computer"
    }
    else {
        C:\temp\temp\tools\paexec.exe \\$computer cmd /C "netsh advfirewall firewall add rule dir=in name ="WMI" program=%systemroot%\system32\svchost.exe service=winmgmt action = allow protocol=TCP localport=any & call netsh firewall set service RemoteAdmin enable & netsh firewall add portopening protocol=tcp port=135 name=DCOM_TCP135"
        }

}


