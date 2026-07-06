# Purpose: version — General-purpose PowerShell utilities.
# Get PowerShell executable file version

# $PsVer = ( Get-command PowerShell ).FileVersionInfo.ProductVersion
# Write-Host "PowerShell Version $PsVer"

$OUTLOOKVer = ( Get-command "C:\program files\microsoft office\office12\OUTLOOK.exe" ).FileVersionInfo.ProductVersion
Write-Host "Outlook Version $OUTLOOKVer %computername%" 

