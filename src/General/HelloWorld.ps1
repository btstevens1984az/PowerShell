# Purpose: HelloWorld — General-purpose PowerShell utilities.
Add-Type -AssemblyName "System.Speech"
$speech = New-object system.speech.synthesis.speechsynthesizer
#$speech.selectvoicebyhints("Male","adult")
$speech.Rate = -10
$text = "To much beer makes you drunk"
$speech.speak($text)