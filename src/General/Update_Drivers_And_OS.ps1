# Purpose: Update Drivers And OS — General-purpose PowerShell utilities.
# Enable TLS12
[Net.ServicePointManager]::SecurityProtocol = [Enum]::ToObject([Net.SecurityProtocolType], 3072)

# Install PSWindowsUpdate
Install-PackageProvider -Name NuGet -Force -Confirm:$false -EA 0 | Out-Null
Install-Module -Name PSWindowsUpdate -Force -Confirm:$false -EA 0 | Out-Null

# Import the PowerShell Module
Import-Module PSWindowsUpdate

# Set update channel
Add-WUServiceManager -ServiceID "7971f918-a847-4430-9279-4a52d1efe18d" -AddServiceFlag 7 -Confirm:$false

# Install or update all drivers
Write-Output 'Checking for driver updates...'
Install-WindowsUpdate -Category Driver -AcceptAll -Install -Verbose

# Install all missing windows updates
Write-Output 'Checking for general Windows updates...'
Install-WindowsUpdate -AcceptAll -Install -AutoReboot -Verbose