# Purpose: Microsoft.PowerShell profile — PowerShell profile and ISE snippets.
# directory where my scripts are stored
$psdir="U:\Functions"
# load all 'autoload' scripts
Get-ChildItem "${psdir}\*.ps1" | %{.$_}
$webclient=New-Object System.Net.WebClient            
$webclient.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
Add-Type -AssemblyName System.Speech
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
$speak.Speak("Your PowerShell Functions are ready for launch Doctor Hurt.")
Disable-UAC
Enable-LogFile -Path 'C:\Temp\PSConsole.log'
Import-Module -Name PSReadline
Set-PSReadlineOption -EditMode Emacs
Set-PSReadlineOption -BellStyle None
CLS
Write-Host "Custom PowerShell Environment Loaded"
