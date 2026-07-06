# Purpose: REG-InstalledPrograms — Windows registry read and write operations.
#   James Wylde

Invoke-Command -ComputerName 165.225.185.176 -ScriptBlock {get-Itemproperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object Displayname, publisher, installdate} | Format-table -AutoSize






# Loop through each entry under Products   
Get-ChildItem Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products -Recurse -Name | ForEach-Object {   
  
# Find your software by its display name   
if ((Get-ItemProperty Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\$_\InstallProperties -Name DisplayName -ErrorAction SilentlyContinue).DisplayName -eq "SAP") {   
  
# Grab the Uninstall String while removing "msiexec /i" from the string   
$UninstallString = (Get-ItemProperty Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\$_\InstallProperties).UninstallString -replace "MsiExec.exe /I", "SAP"   
}   
}   
  
# Uninstall software   
Start-Process MsiExec.exe -ArgumentList "/x $UninstallString /passive" -Wait
