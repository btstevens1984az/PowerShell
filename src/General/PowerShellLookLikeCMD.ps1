# Purpose: PowerShellLookLikeCMD — General-purpose PowerShell utilities.
#make Powershell look like CMD
$host.ui.RawUI.WindowTitle = "Command Prompt"
$host.ui.RawUI.BackgroundColor = "black"
function prompt {
"$($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) "
}
cls