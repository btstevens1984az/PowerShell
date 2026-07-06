# Purpose: Tune Windows 10 Preferences — General-purpose PowerShell utilities.
#/Services
## Disables diagnostics tracking services, various Xbox services, and Windows Media Player network sharing (you can turn this back on if you share your media libraries with WMP)
Get-Service Diagtrack,XblAuthManager,XblGameSave,XboxNetApiSvc,WMPNetworkSvc -EA 0 | Stop-Service -PassThru | Set-Service -StartupType Disabled


#/Non Local-GP Settings
## Disabling advertising info and device metadata collection for this machine
Reg Add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /T REG_DWORD /V "Enabled" /D 0 /F | Out-Null
Reg Add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /V "PreventDeviceMetadataFromNetwork" /T REG_DWORD /D 1 /F | Out-Null
Write-Output 'Disabled Microsoft advertising services'


#/Windows Update
## Turn off featured software notifications through WU (basically ads)			
Reg Add	"HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /T REG_DWORD /V "EnableFeaturedSoftware" /D 0 /F | Out-Null
Write-Output 'Disabled Microsoft new application advertising'


#/Delivery optimization			
## Disable DO; set to 1 to allow DO over LAN only			
Reg Add	"HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /T REG_DWORD /V "DODownloadMode" /D 1 /F | Out-Null
Write-Output 'Disabled WAN update sharing, enabled local update sharing'


#/Microsoft Edge			
## Always send do not track			
Reg Add	"HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" /T REG_DWORD /V "DoNotTrack" /D 1 /F | Out-Null
Write-Output 'Set Edge to Do Not Track'


#/Data Collection and Preview Builds			
## Set Telemetry to basic (switches to 1:basic for W10Pro and lower, disabled altogether by disabling service anyways)			
Reg Add	"HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /T REG_DWORD /V "AllowTelemetry" /D 0 /F | Out-Null
## Disable pre-release features and settings			
Reg Add	"HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" /T REG_DWORD /V "EnableConfigFlighting" /D 0 /F | Out-Null
## Do not show feedback notifications			
Reg Add	"HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /T REG_DWORD /V "DoNotShowFeedbackNotifications" /D 1 /F | Out-Null
Write-Output 'Disabled pre-release builds and data collection notifications'


#/Cloud Content			
## Do not show Windows Tips			
Reg Add	"HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /T REG_DWORD /V "DisableSoftLanding" /D 1 /F | Out-Null
## Turn off Consumer Experiences			
Reg Add	"HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /T REG_DWORD /V "DisableWindowsConsumerFeatures" /D 1 /F | Out-Null
Write-Output 'Disabled Windows 10 tips and consumer experience (ads / live tiles in the start menu)'


#/Search
## Disallow web search from desktop search			
Reg Add	"HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /T REG_DWORD /V "DisableWebSearch" /D 1 /F | Out-Null
## Don't search the web or display web results in search			
Reg Add	"HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /T REG_DWORD /V "ConnectedSearchUseWeb" /D 0 /F | Out-Null
Write-Output 'Disabled bing/web search from the start menu'


#/Enable Wake on LAN
## You still need to enable Wake on LAN in UEFI/BIOs but this will at least make sure the OS is ready for it
## This completes 4 tasks...
## 1. "Allow the device to wake the computer" to CHECKED
## 2. "Only allow a magic packet to wake the computer" to CHECKED
## 3. "Energy Efficient Ethernet" to OFF
## 4. Fast Startup to DISABLED (Windows 8-10 only)

$nic = Get-NetAdapter | ? { ($_.MediaConnectionState -eq "Connected") -and (($_.name -match "Ethernet") -or ($_.name -match "local area connection")) }
$nicPowerWake = Get-WmiObject MSPower_DeviceWakeEnable -Namespace root\wmi | Where-Object { $_.instancename -match [regex]::escape($nic.PNPDeviceID) }
If ($nicPowerWake) {
    If ($nicPowerWake.Enable) {
        ## All good here
        Write-Output "MSPower_DeviceWakeEnable is true"
    } Else {
        Write-Output "MSPower_DeviceWakeEnable is false. Setting to true..."
        $nicPowerWake.Enable = $True
        $nicPowerWake.psbase.Put()
    }
} Else {
    Write-Warning "Unable to find the property MSPower_DeviceWakeEnable"
}

$nicMagicPacket = Get-WmiObject MSNdis_DeviceWakeOnMagicPacketOnly -Namespace root\wmi | Where-Object { $_.instancename -match [regex]::escape($nic.PNPDeviceID) }
If ($nicMagicPacket) {
    If ($nicMagicPacket.EnableWakeOnMagicPacketOnly) {
        ## All good here
        Write-Output "EnableWakeOnMagicPacketOnly is true"
    } Else {
        Write-Output "EnableWakeOnMagicPacketOnly is false. Setting to true..."
        $nicMagicPacket.EnableWakeOnMagicPacketOnly = $True
        $nicMagicPacket.psbase.Put()
    }
} Else {
    Write-Warning "Unable to find the property EnableWakeOnMagicPacketOnly"
}

## Since different NICs will have different registry keys, this recursively scans through the reigstry to find the
## the EEELinkAdvertisement property
$FindEEELinkAd = Get-ChildItem "hklm:\SYSTEM\ControlSet001\Control\Class" -Recurse -EA 0 | % { Get-ItemProperty $_.pspath } -EA 0 | ? { $_.EEELinkAdvertisement } -EA 0
If ($FindEEELinkAd.EEELinkAdvertisement -eq 1) {
    Set-ItemProperty -Path $FindEEELinkAd.PSPath -Name EEELinkAdvertisement -Value 0
    ## Check again
    $FindEEELinkAd = Get-ChildItem "hklm:\SYSTEM\ControlSet001\Control\Class" -Recurse -EA 0 | % { Get-ItemProperty $_.pspath } | ? { $_.EEELinkAdvertisement }
    If ($FindEEELinkAd.EEELinkAdvertisement -eq 1) {
        Write-Output "!ERROR: EEELinkAdvertisement set to $($FindEEELinkAd.EEELinkAdvertisement)"
    } Else {
        Write-Output "!SUCCESS: EEELinkAdvertisement set to $($FindEEELinkAd.EEELinkAdvertisement)"
    }
} Else {
    Write-Output "EEELinkAdvertisement is already turned off"
}

## Disable Fast Startup in Windows 8-10 (Fast Startup breaks Wake On LAN)
If ((gwmi win32_operatingsystem).caption -match "Windows 8") {
    Write-Output "Windows 8.x detected. Disabling Fast Startup, as this breaks Wake On LAN..."
    powercfg -h off
} ElseIf ((gwmi win32_operatingsystem).caption -match "Windows 10") {
    Write-Output "Windows 10 detected. Disabling Fast Startup, as this breaks Wake On LAN..."
    ## This checks if HiberbootEnabled is equal to 1
    $FindHiberbootEnabled = Get-ItemProperty "hklm:\SYSTEM\CurrentControlSet\Control\Session?Manager\Power" -EA 0
    If ($FindHiberbootEnabled.HiberbootEnabled -eq 1) {
        Write-Output "HiberbootEnabled is Enabled. Setting to disabled..."
        Set-ItemProperty -Path $FindHiberbootEnabled.PSPath -Name "HiberbootEnabled" -Value 0 -Type DWORD -Force | Out-Null
    } Else {
        Write-Output "HiberbootEnabled is already disabled"
    }
}