# Purpose: Disable-SMBv1 — PowerShell automation.
Function Disable-SMBv1 {
try{
    Set-SmbServerConfiguration -EnableSMB1Protocol $false -EnableSMB2Protocol $true -Confirm:$False -ErrorAction SilentlyContinue
}
Catch{    
    sc.exe config lanmanworkstation depend= bowser/mrxsmb20/nsi
    sc.exe config mrxsmb10 start= disabled
    sc.exe config lanmanworkstation depend= bowser/mrxsmb10/mrxsmb20/nsi 
    sc.exe config mrxsmb20 start= auto
}    
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" SMB1 -Type DWORD -Value 0 -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" SMB2 -Type DWORD -Value 1 -Force -ErrorAction SilentlyContinue

#Uninstall SMBv1
if((Get-WmiObject -class Win32_OperatingSystem).Name -like '*server*'){
    Remove-WindowsFeature FS-SMB1 -ErrorAction SilentlyContinue | Out-Null
}
else{
    Disable-WindowsOptionalFeature -Online -FeatureName smb1protocol -NoRestart -ErrorAction SilentlyContinue | Out-Null
}
}
