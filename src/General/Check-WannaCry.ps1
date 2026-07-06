# Purpose: Check-WannaCry — General-purpose PowerShell utilities.
Function Check-WannaCry {
[CmdletBinding()] 
param( 
  [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
  [Alias("CN","Computer")] 
  [String[]]$ComputerName
  )
$os = "Microsoft Windows 10 Enterprise 2016 LTSB"

#Get server Operating System
Function Get-OperatingSystemVersion
{
    (Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ComputerName).caption
}

#Check server to see if hotfix is installed
Function Get-HotfixID
{
    $Hotfix1 = (Get-Hotfix -ComputerName $ComputerName | where -Property HotFixID -Contains "KB4023834")
    $Hotfix2 = (Get-Hotfix -ComputerName $ComputerName | where -Property HotFixID -Contains "KB4013418")

}

#Want to check OS version and if 2012, then check for KB
if ((Get-OperatingSystemVersion) -eq $os) {
    if(Get-HotFixId) {
        "$ComputerName OS is $(Get-OperatingSystemVersion) and you already have the patch."
    }
    Else {
        "$ComputerName OS is $(Get-OperatingSystemVersion) and you NEED the patch."
    }
}
Else {
    "$ComputerName OS is $(Get-OperatingSystemVersion)."
}
}