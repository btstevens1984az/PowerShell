# Purpose: SapiCom — General-purpose PowerShell utilities.
$s = new-object -com SAPI.SpVoice
$s.rate = -10
$s.speak(“Too much beer makes you drunk”)
$s.rate = -2
$s.speak("Unknown error. You have really messed things up this time. Your administrative rights have been revoked")