# Purpose: sapitimer — General-purpose PowerShell utilities.
Do
{
	Start-Sleep -Seconds 1
} until ((Get-Date ) -ge (Get-Date -Hour 16 -Minute 50))

Add-Type -AssemblyName "SYSTEM.SPEECH"
$sapi = new-object system.speech.synthesis.speechsynthesizer
$sapi.rate = -5
$sapi.speak("40 minute warning")