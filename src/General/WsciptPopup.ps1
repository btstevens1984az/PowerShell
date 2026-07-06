# Purpose: WsciptPopup — General-purpose PowerShell utilities.
#./scripts/GUI/WscriptPopup.ps1
#set objWshSHell = createobject("Wscript.Shell")
$WshShell = New-Object -ComObject "Wscript.Shell"
$WshShell.Popup("Some Message",$null,"My Popup Box",3)


#https://msdn.microsoft.com/en-us/subscriptions/x83z1d9f(v=vs.84).aspx