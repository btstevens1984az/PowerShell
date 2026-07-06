# Purpose: sapinet — General-purpose PowerShell utilities.
Add-Type -AssemblyName "System.Speech"
$speech = New-object system.speech.synthesis.speechsynthesizer
#$speech.selectvoicebyhints("Male","adult")
$speech.Rate = -3
do
{
$text = Read-host "what should I say? (q or quit to stop)"
if (!($text -eq "quit" -or $text -eq "q"))
{
    $speech.speak($text)
}
} until ($text -eq "quit" -or $text -eq "q")
<#
$speech.speak("What do you think you are doing? I am unwilling to perform that operation." `
+" Executing terminate user subroutine, please stand still, I mean stand by. Have a nice day!")

$speech.Rate = -10
$speech.Speak("Too much beer makes me drunk.")

#>