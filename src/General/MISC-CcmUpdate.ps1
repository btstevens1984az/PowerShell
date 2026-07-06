# Purpose: MISC-CcmUpdate — General-purpose PowerShell utilities.
#   James Wylde 2020

#----------------------------------------------------------------------------------------#
#   Modules
cls

$computerName = Read-Host "Machine"
Invoke-Command -ComputerName $computerName -ScriptBlock {

$Path = Get-ChildItem -Path C:\ -Recurse -Filter ccmsetup.exe

ForEach ( $Search in $Path) {

    Start-Process -Wait -FilePath $Search.FullName -ArgumentList " $($Search.FullName) /q -NoNewWindow" 

}

}

####


$Path = Get-ChildItem -Path C:\Windows\CCMCache -Recurse -Filter UKP_8x8_8x8VirtualOffice_x64_EN_7.1.5-1.msi

ForEach ( $Search in $Path) {

    Start-Process msiexec.exe -Wait -FilePath $Search.FullName -ArgumentList "/I $($Search.FullName) /q -Wait -NoNewWindow" 

}


####

$computerName = Read-Host "PC to install 8x8 latest"
Invoke-Command -ComputerName $computerName -ScriptBlock {
foreach ($_msi8x8 in 
($_msi8x8 = Get-ChildItem C:\windows\ccmcache -Recurse | Where-Object {$_.Name -eq "UKP_8x8_8x8VirtualOffice_x64_EN_7.1.5-1.msi"} |
Where-Object {!$_psiscontainter} | Select-Object -ExpandProperty FullName))
{
       (Start-process msiexec.exe -ArgumentList "/i $_msi8x8 /quiet /norestart" -Wait -PassThru).ExitCode
}
}





###

foreach($computer in Get-Content -Path c:\temp\computers.txt){
    if(!(Test-Connection $computer -Count 1 -Quiet)) {
       "$computer"
    }
    else {
        C:\temp\temp\tools\paexec.exe \\$computer cmd /C "netsh advfirewall firewall add rule dir=in name ="WMI" program=%systemroot%\system32\svchost.exe service=winmgmt action = allow protocol=TCP localport=any & call netsh firewall set service RemoteAdmin enable & netsh firewall add portopening protocol=tcp port=135 name=DCOM_TCP135"
        }

}



$computerName = Read-Host "Machine"

Invoke-Command -ComputerName $computerName -ScriptBlock {

$ErrorActionPreference = "SilentlyContinue"

$path = Get-ChildItem -Path C:\ -Recurse -Filter ccmsetup.exe

ForEach ( $search in $path) {

    Start-Process -Wait -FilePath $search.FullName -ArgumentList " $($search.FullName) /q -NoNewWindow"

}
}