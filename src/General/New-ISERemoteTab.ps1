# Purpose: New-ISERemoteTab — General-purpose PowerShell utilities.
Import-Module ISERemoteTab

$Display = "New Remote ISE Tab"
$Action = {New-ISEREmoteForm}
$Shortcut = "Ctrl+Shift+T"
$ISERemoteProfile = "C:\Scripts\RemoteProfile.ps1"

$psise.CurrentPowerShellTab.AddOnsMenu.Submenus.Add($Display,$Action,$shortcut) | Out-Null