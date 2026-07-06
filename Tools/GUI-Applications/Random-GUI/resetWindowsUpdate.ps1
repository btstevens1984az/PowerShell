# Purpose: resetWindowsUpdate — Standalone GUI applications and utilities.
# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))

   {
       # We are running "as Administrator" - so change the title and background color to indicate this
       $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
       $Host.UI.RawUI.BackgroundColor = "DarkBlue"
       clear-host
   }

else
   {
       # We are not running "as Administrator" - so relaunch as administrator   

       # Create a new process object that starts PowerShell
       $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";   

       # Specify the current script path and name as a parameter
       $newProcess.Arguments = $myInvocation.MyCommand.Definition;   

       # Indicate that the process should be elevated
       $newProcess.Verb = "runas";   

       # Start the new process
       [System.Diagnostics.Process]::Start($newProcess);   

       # Exit from the current, unelevated, process
       # exit
   } 

# Running  code that needs to be elevated here
net stop bits
net stop wuauserv
net stop appidsvc
net stop cryptsvc
del "$env:ALLUSERSPROFILE\Application Data\Microsoft\Network\Downloader\qmgr*.dat"
ren "$env:SystemRoot\SoftwareDistribution"  SoftwareDistribution.bak
ren "$env:SystemRoot\system32\catroot2" catroot2.bak
cmd.exe /c "sc.exe sdset bits D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
cmd.exe /c "sc.exe sdset wuauserv D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
cd C:\WINDOWS\System32\
$dlls = @("atl.dll", "urlmon.dll", "mshtml.dll", "shdocvw.dll", "browseui.dll", "jscript.dll", "vbscript.dll", "scrrun.dll", "msxml.dll", "msxml3.dll", "msxml6.dll", "actxprxy.dll", "softpub.dll", "wintrust.dll", "dssenh.dll", "rsaenh.dll", "gpkcsp.dll", "sccbase.dll", "slbcsp.dll", "cryptdlg.dll", "oleaut32.dll", "ole32.dll", "shell32.dll", "initpki.dll", "wuapi.dll", "wuaueng.dll", "wuaueng1.dll", "wucltui.dll", "wups.dll", "wups2.dll", "wuweb.dll", "qmgr.dll", "qmgrprxy.dll", "wucltux.dll", "muweb.dll", "wuwebv.dll")
foreach ($dll in $dlls) {
   $startInfo = New-Object Diagnostics.ProcessStartInfo
   $startInfo.Filename = "regsvr32.exe"
   $startInfo.Arguments = "/s " + $dll
   $startInfo.RedirectStandardError = $true
   $startInfo.CreateNoWindow = $true
   ## Start the process
   $startInfo.UseShellExecute = $false
   [Diagnostics.Process]::Start($startInfo)
}
.\netsh winsock reset 
#the old way to reset proxy is below
#.\cmd.exe /c "proxycfg.exe -d"
.\netsh.exe winhttp reset proxy

Write-Host "Please press any key to continue..." | Out-Null
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")| Out-Null