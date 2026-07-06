# Purpose: Install-AdobeAcrobatReaderDC — Reusable PowerShell function libraries.
Function Install-AdobeAcrobatReaderDC {
# Silent install Adobe Reader DC
# https://get.adobe.com/nl/reader/enterprise/
$ComputerNames = Get-Content -Path 'C:\Users\$env:USERNAME\Desktop\10031.txt'
# Path for the workdir
$workdir = "\\$ComputerName\C$\Temp\"

foreach ($ComputerName in $ComputerNames) {

# Check if work directory exists if not create it
If (Test-Path -Path $workdir -PathType Container)
{ Write-Host "$workdir already exists" -ForegroundColor Red}
ELSE
{ New-Item -Path $workdir -ItemType Directory }

# Copy the Installer
$source = "\\186.189.182.154\share`$\Software_Repository\Adobe\Adobe Reader\AReaderDC\readerdc_en_xa_install.exe"
$destination = "$workdir\readerdc_en_xa_install.exe"
Copy-Item -Container $source -Destination $destination -Force

# Start the installation
#$silentArgs = '/msi EULA_ACCEPT=YES /qn'
Start-Process -FilePath "$workdir\readerdc_en_xa_install.exe" -ArgumentList "/sAll /rs /rps /msi /norestart /quiet EULA_ACCEPT=YES"
# Wait XX Seconds for the installation to finish
Start-Sleep -s 240

# Remove the installer
Remove-Item -Path '\\$ComputerName\$workdir\readerdc_en_xa_install.exe' -Force
}
}
<#
For Windows 7 please change 
#From
$source = "http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/1502320053/AcroRdrDC1502320053_en_US.exe"
$destination = "$workdir\adobeDC.exe"
Invoke-WebRequest $source -OutFile $destination

#To
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/1502320053/AcroRdrDC1502320053_en_US.exe","$workdir\adobeDC.exe")
#> 
