# Purpose: Install-FireFox — PowerShell automation.
Function Install-FireFox {
# Path for the workdir
$workdir = "C:\Temp\"

# Check if work directory exists if not create it
If (Test-Path -Path $workdir -PathType Container)
{ Write-Host "$workdir already exists" -ForegroundColor Red}
ELSE
{ New-Item -Path $workdir  -ItemType directory }

# Download the installers
#$vscode = "http://go.microsoft.com/fwlink/?LinkID=623230"
#$destination1 = "$workdir\vscode.exe"
$firefox = "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=en-US"
$destination2 = "$workdir\firefox.exe"
#$python = "https://www.python.org/ftp/python/3.6.5/python-3.6.5.exe"
#$destination3 = "$workdir\python-3.6.5.exe"
#$pscore = "https://github.com/PowerShell/PowerShell/releases/download/v6.0.2/PowerShell-6.0.2-win-x64.msi"
#$destination4 = "$workdir\PowerShell-6.0.2-win-x64.msi"
#$discord = 'https://discordapp.com/api/download?platform=win'
#$destination5 = "$workdir\discordapp.exe"


# Check if Invoke-Webrequest exists otherwise execute WebClient
# Turning off progress bars for Invoke-WebRequest because they are garbage
$ProgressPreference = 'SilentlyContinue'

if (Get-Command 'Invoke-Webrequest')
{
    #Invoke-WebRequest $vscode -OutFile $destination1
    Invoke-WebRequest $firefox -OutFile $destination2
	#Invoke-WebRequest $python -OutFile $destination3
    #Invoke-WebRequest $pscore -OutFile $destination4
    #Invoke-WebRequest $discord -OutFile $destination5
}
else
{
    #$WebClient = New-Object System.Net.WebClient
    #$webclient.DownloadFile($vscode, $destination1)
    $WebClient = New-Object System.Net.WebClient
    $webclient.DownloadFile($firefox, $destination2)
    #$WebClient = New-Object System.Net.WebClient
    #$webclient.DownloadFile($python, $destination3)
    #$WebClient = New-Object System.Net.WebClient
    #$webclient.DownloadFile($pscore, $destination4)
    #$WebClient = New-Object System.Net.WebClient
    #$webclient.DownloadFile($discord, $destination5)
}

$ProgressPreference = 'Continue'

#Start the installation
Start-Process -FilePath "$workdir\firefox.exe" -ArgumentList "/S"
#Start-Process -FilePath "$workdir\vscode.exe" -ArgumentList "/S"
#Start-Process -FilePath "$workdir\python-3.6.5.exe" -ArgumentList "/S"
#msiexec /i "$workdir\PowerShell-6.0.2-win-x64.msi" /quiet /qn /norestart
#Start-Process -FilePath "$workdir\discord.exe" -ArgumentList "/S"

#Wait 35 Seconds for the installation to finish
    Start-Sleep -s 35
#Remove the installer
    rm -Force $workdir\firefox*
    }