# Purpose: MISC-EnableRDP — General-purpose PowerShell utilities.
#   James Wylde 2020

#----------------------------------------------------------------------------------------#
#   Reg RDS fix

Enter-PSSession -ComputerName 168.23.139.1 -Credential group\a2-wyldeja

Set-Itemproperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fdenytsconnections" -Value 0

Enable-NetFirewallRule -DisplayGroup "Remote Desktop"


#----------------------------------------------------------------------------------------#
#   Psexec WINRM

psexec.exe \\PC01 -s c:\windows\system32\winrm.cmd quickconfig -quiet

REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
netsh firewall set service type = remotedesktop mode = enable
nable & netsh advfirewall firewall add rule name="Open Remote Desktop" protocol=TCP dir=in localport=3389 action=allow
#----------------------------------------------------------------------------------------#
#   WMI WINRM

$SessionArgs = @{
    ComputerName  = 'Uk-nor1-l28951'
    Credential    = Get-Credential
    SessionOption = New-CimSessionOption -Protocol Dcom
}
$MethodArgs = @{
    ClassName     = 'Win32_Process'
    MethodName    = 'Create'
    CimSession    = New-CimSession @SessionArgs
    Arguments     = @{
        CommandLine = "powershell Start-Process powershell -ArgumentList 'Enable-PSRemoting -Force'"
    }
}
Invoke-CimMethod @MethodArgs


#----------------------------------------------------------------------------------------#
#   Enable c$

psexec.exe \\PC01 reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\system" /v "LocalAccountTokenFilterPolicy" /t REG_DWORD /d 1 /f

#----------------------------------------------------------------------------------------#
#   Firewall exception

Invoke-Command -ComputerName 168.23.139.1 -ScriptBlock { Set-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True -Profile Private }

nable & netsh advfirewall firewall add rule name="Open Remote Desktop" protocol=TCP dir=in localport=3389 action=allow



###
netsh firewall set domainprofile
netsh advfirewall monitor show consec verbose > c:\temp\output.txt