# Purpose: Microsoft.PowerShell profile — Storage management and disk operations.

# directory where HPCA scripts are stored

$psdir="C:\HPCA\WPS\Modules"  

Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager'

# load all 'autoload' scripts
Write-host "Loading" -NoNewline
 
Get-ChildItem "${psdir}\*.ps1" | %{.$_
    Write-host "." -NoNewline
}
Write-Host "  HPCA Scripts loaded Now loading Local Profile functions"

# directory where Standard scripts are stored

$psdirlocal="C:\Users\kkreitinger\Documents\WindowsPowerShell\Modules"  

# load all 'autoload' scripts
Write-host "Loading" -NoNewline
 
Get-ChildItem "${psdirlocal}\*.ps1" | %{.$_
    Write-host "." -NoNewline
}


Write-Host " Done"
Set-Location C:\
$console = $host.UI.RawUI
$console.WindowTitle = "Kerry's PS Profile 2017"
$console.BackgroundColor = "1E6DC7"
$console.ForegroundColor = "GRAY"

$buffer = $console.BufferSize
$buffer.Width = 120
$buffer.Height = 9999
$console.BufferSize = $buffer
 
$size = $console.WindowSize
$size.Width = 100
$size.Height = 45
$console.WindowSize = $size




Function Get-ComputerInformationWMI
{
    # Computer System
    Get-WmiObject -Class Win32_ComputerSystem
    # Operating System
    Get-WmiObject -class win32_OperatingSystem
    # BIOS
    Get-WmiObject -class win32_BIOS
	
}

function Get-InfoBadService {
[CmdletBinding()]
param(
[Parameter(Mandatory=$True)][string]$ComputerName
)
$svcs = Get-WmiObject -class Win32_Service -ComputerName $ComputerName `
-Filter "StartMode='Auto' AND State<>'Running'"
foreach ($svc in $svcs) {
$props = @{'ServiceName'=$svc.name;
'LogonAccount'=$svc.startname;
'DisplayName'=$svc.displayname}
New-Object -TypeName PSObject -Property $props
}
}

function Get-McAfeeProcess
{
 Get-Process |Where-Object {$_.Company -like 'McAfee*'} | ft
 }
 
 function Get-MicrosoftProcess
{
 Get-Process |Where-Object {$_.Company -like 'Microsoft*'} | ft
 }
 
 function Get-BIOS {
 if ((Get-ItemProperty HKLM:\System\CurrentControlSet\control\SecureBoot\State -ErrorAction SilentlyContinue) -eq $null ) {"BIOS Detected"} else {"UEFI Detected"}
 }
 
 
function Get-Uptime {
   $os = Get-WmiObject win32_operatingsystem
   $uptime = (Get-Date) - ($os.ConvertToDateTime($os.lastbootuptime))
   $Display = "Uptime: " + $Uptime.Days + " days, " + $Uptime.Hours + " hours, " + $Uptime.Minutes + " minutes" 
   Write-Output $Display
}

# POWERSHELL ISE DOES NOT USE THE COMMAND BUFFER SO THIS IS NOT APPLICABLE TO ISE
Function Set-InvokedCommand {
[cmdletbinding()]
Param(
[Parameter(Position=0,Mandatory,HelpMessage="Enter a command history ID number")]
[int]$ID
)
 
Add-Type -AssemblyName "microsoft.visualbasic" -ErrorAction Stop 
 
$prompt = "Modify the command"
$title = "Run History"
Try {
$cmdText = (Get-History -Id $ID -ErrorAction Stop).CommandLine
 
[string]$cmd = [microsoft.visualbasic.interaction]::InputBox($Prompt,$Title,$CmdText)
 
if ($cmd) {
    Invoke-Expression -Command $cmd
}
}
Catch {
    Throw $_
}
} #end function

clear-host
write-host
write-host Functions Available - Get-Uptime Set-InvokedCommand Get-ComputerInformationWMI Get-McAfeeProcess
write-host Functions Available -  Get-InfoBadService Get-BIOS
write-host "          Profile Paths being used for this session:    "
$PSDir
$Profile