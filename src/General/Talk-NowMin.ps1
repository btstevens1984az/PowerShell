# Purpose: Talk-NowMin — General-purpose PowerShell utilities.
# powershell to speak

# .Net methods for hiding/showing the console in the background
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
function Hide-Console
{
    $consolePtr = [Console.Window]::GetConsoleWindow()
    #0 hide
    [Console.Window]::ShowWindow($consolePtr, 0)
}
Hide-Console
 
Add-Type -AssemblyName System.Speech

$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer

# simple speak command
$speak.Speak("Hello how are you today?")

# set loop to speak repeatedly
while ($true) {
    $speak.Speak("The current time is $((Get-Date).ToShortTimeString())")
    Start-Sleep -Seconds 600 
} 

# say the time   -input "The current time is $((Get-Date).ToShortTimeString())"
#$speak.Speak("The current time is $((Get-Date).ToShortTimeString())")

#start-sleep 600

