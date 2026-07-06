# Purpose: Talk-Now — General-purpose PowerShell utilities.
# powershell to speak

 
Add-Type -AssemblyName System.Speech
$synth = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer
$synth.Speak('What shall we do now?')


# to save speech output to a file for use later
#$speak.SetOutputToWaveFile("C:\temp\test.wav")
#$speak.Speak("Please your computer every day")
#$speak.Dispose()

$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer

# show speech objects
$speak | Get-Member

# simple speak command
$speak.Speak("Hell0 how are you today?")

# to show voice - default is male
$speak.voice

#show available voices
$speak.GetInstalledVoices()

$speak.GetInstalledVoices().VoiceInfo

# set voice to desired available voice  - this female 
$speak.SelectVoice('Microsoft Zira Desktop')

$speak.Speak("Hell0 how are you today?")

# say the time   -input "The current time is $((Get-Date).ToShortTimeString())"
$speak.Speak("The current time is $((Get-Date).ToShortTimeString())")