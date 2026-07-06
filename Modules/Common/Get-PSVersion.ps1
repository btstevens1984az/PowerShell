Function Get-PSVersion {
<#
.Synopsis
Get a short view of PowerShell version information
 
.Description
Use this command to get a quick snapshot of PowerShell version information. The
Remoting property should indicate what remoting capabilities are potentially
available.
 
.Example
PS C:\> Get-PSVersion
 
Edition      : Desktop
Platform     : Windows
Remoting     : {WinRM}
Computername : Win10Desk
 
Running on a Windows 10 desktop.
 
.Example
PS C:\> Get-PSVersion
 
 
Edition      : Core
Platform     : Win32NT
Remoting     : {WinRM, SSH}
Computername : SRV1
 
Running PowerShell Core on a Windows platform with SSH installed.
 
.Example
PS /mnt/c/scripts> get-psversion
 
 
Edition      : Core
Platform     : Unix
Remoting     : {SSH}
Computername : Bovine320
 
PowerShell Core running in a Linux environment.
 
.Link
$PSVersionTable
 
 
#>
[cmdletbinding()]
Param()
 
$ver = $PSVersionTable.PSVersion
$edition = $PSVersionTable.PSEdition
 
if ($PSVersionTable.platform) {
    $platform = $PSVersionTable.platform
}
else {
    $platform = "Windows"
}
 
$remoting = @()
if (Test-Path 'WSMan:') {
    $remoting+="WinRM"
}
if (Get-Command ssh -ErrorAction SilentlyContinue) {
    $remoting+="SSH"
}
 
#use the hostname command because non-windows systems won't have
#$env:computername.
[pscustomobject]@{
    Version = $ver
    Edition = $edition
    Platform = $platform
    Remoting = $Remoting
    Computername = $(hostname)
}
 
}
