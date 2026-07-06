# Purpose: Java-RemoveAllOldVersions — Reusable PowerShell function libraries.
Function Java-RemoveAllOldVersions {
<#This script is used to remove any old Java versions, and leave only the newest.
Original Source Author: mmcpherson
Source URL: https://www.lansweeper.com/forum/yaf_postst10942_Script---Remove-Old-Java-Versions-Silently.aspx#post40908
            - Now also detects and removes old Java non-update base versions (i.e. Java versions without Update #)
            - Now also removes Java 6 and below, plus added ability to manually change this behaviour.
            - Added uninstall default behaviour to never reboot (now uses msiexec.exe for uninstall)
            - Bug fixes: null array and op_addition errors.
			- Added check to have script run as Administrator.
			- Added check to see of java is running and to kill it
			- Added check to find newest java install in script location
			- Installs latest java in script location
            - Bug fixes: typos when launching installs
			- Bug fixes: Changed [string]::IsNullOrWhiteSpace to [string]::IsNullOrEmpty to work on older PS boxes
			- Bug fixes: How java processes are killed.
				- Added a time out to the loop.
			- Added Transcript logging
IMPORTANT NOTE: If you would like Java versions 6 and below to remain, please edit the next line and replace $true with $false
#>
$ScriptVersion = "1.5"
$UnInstall6andBelow = $true
$InstallOptions = "/s INSTALL_SILENT=1 STATIC=0 REBOOT=0 AUTO_UPDATE=0 EULA=0 WEB_ANALYTICS=0 WEB_JAVA=1"
$KillProcessTimeoutSec = 90
$LogFile = ("C:\Backups\" + $MyInvocation.MyCommand.Name + "_" + (Get-Date -format yyyyMMdd-hhmm) + ".log")
#Current Script location
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition 
$objProcessor  = (Get-WmiObject -Class Win32_OperatingSystem  -ea 0).OSArchitecture

#Declare arrays
$AlreadyInstalled = @{}
$Install = @{}
$SetupFiles = @{}
$32bitJava = @()
$64bitJava = @()

#Force Starting of Powershell script as Administrator 
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
	$arguments = "& '" + $myinvocation.mycommand.definition + "'"
	Start-Process powershell -Verb runAs -ArgumentList $arguments
	Break
}
# Start-Transcript Log
If (-NOT ([string]::IsNullOrEmpty($LogFile))) {
    If (-NOT (Test-Path (Split-Path -Parent -Path $LogFile))) {
		New-Item (Split-Path -Parent -Path $LogFile) -type directory
	}
	Start-Transcript -Path $LogFile -Append
	Write-Host ("Script: " + $MyInvocation.MyCommand.Name)
	Write-Host ("Version: " + $ScriptVersion)
	Write-Host (" ")
}


#################Functions#################
function Test-is64Bit {
    param($FilePath)
    #Source: https://superuser.com/questions/358434/how-to-check-if-a-binary-is-32-or-64-bit-on-windows
    If (Test-Path($FilePath)) {
    [int32]$MACHINE_OFFSET = 4
    [int32]$PE_POINTER_OFFSET = 60

    [byte[]]$data = New-Object -TypeName System.Byte[] -ArgumentList 4096
    $stream = New-Object -TypeName System.IO.FileStream -ArgumentList ($FilePath, 'Open', 'Read') 
    $stream.Read($data, 0, 4096) | Out-Null

    [int32]$PE_HEADER_ADDR = [System.BitConverter]::ToInt32($data, $PE_POINTER_OFFSET)
    [int32]$machineUint = [System.BitConverter]::ToUInt16($data, $PE_HEADER_ADDR + $MACHINE_OFFSET)

    $result = "" | select FilePath, FileType, Is64Bit
    $result.FilePath = $FilePath
    $result.Is64Bit = $false

    switch ($machineUint) 
    {
        0      { $result.FileType = 'Native' }
        0x014c { $result.FileType = 'x86' }
        0x0200 { $result.FileType = 'Itanium' }
        0x8664 { $result.FileType = 'x64'; $result.is64Bit = $true; }
    }
    }else {
         Write-Host ("Invalid file: " + $FilePath)
    }
    return $result

}

#################Functions#################
#call kill process until true
$startDate = Get-Date
$result = $false
do {
	#Kill all Java
	$colProcesses = Get-WmiObject  -Class Win32_Process | Where-Object {$_.Name -eq 'jqs.exe' -or $_.Name -eq 'jusched.exe' -or $_.Name -eq 'jucheck.exe' -or $_.Name -eq 'jp2launcher.exe' -or $_.Name -eq 'java.exe' -or $_.Name -eq 'javaws.exe' -or $_.Name -eq 'javaw.exe'}
	#Cycle through found problematic processes and kill them.
	If ($colProcesses) {
		Foreach ($objProcess in $colProcesses) {
		  try{
		   Write-Host $("Found process " + $objProcess.Name + ".")
		   $objProcess.Terminate()
		   $result = $true
		   } catch {
			   switch($LastExitCode) {
				   0 {
								Write-Host $("Killed process " + $objProcess.Name + ".")
					 }
				   -2147217406 {
								Write-Host $("Process " + $objProcess.Name + " already closed.")
								}
				   default {
							   Write-Host $("Could not kill process " + $objProcess.Name)
							   Write-Host $("Error Number: " + $LastExitCode)
							   Write-Host $("Error Message: " + $_.Exception.Message)
							   Write-Host $("Finished problematic process check.")
							   Write-Host $("----------------------------------")
							   If ($startDate.AddSeconds($KillProcessTimeoutSec) -ge (Get-Date)) {
									Write-Host $("Timeout (Seconds): " + $KillProcessTimeoutSec + " reached.")
									exit
							   }
							   
							}
			   }
			}

		}

	}else {
		Write-Host $("No Processes to kill.")
		$result = $true
	}	
} while ( $result -eq $false)

#Perform WMI query to find installed Java Updates
Write-Host("Finding old Java ...")
if ($UnInstall6andBelow) {
    #Also find Java version 5, but handled slightly different as CPU bit is only distinguishable by the GUID
    $32bitJava += Get-WmiObject -Class Win32_Product | Where-Object { 
        ($_.Name -match "(?i)Java(\(TM\))*\s\d+(\sUpdate\s\d+)*$") -or `
        (($_.Name -match "(?i)J2SE\sRuntime\sEnvironment\s\d[.]\d(\sUpdate\s\d+)*$") -and ($_.IdentifyingNumber -match "^\{32"))
    }
} else {
    $32bitJava += Get-WmiObject -Class Win32_Product | Where-Object { 
        $_.Name -match "(?i)Java((\(TM\) 7)|(\s\d+))(\sUpdate\s\d+)*$"
    }
}
 
#Perform WMI query to find installed Java Updates (64-bit)
if ($UnInstall6andBelow) {
    #Also find Java version 5, but handled slightly different as CPU bit is only distinguishable by the GUID
    $64bitJava += Get-WmiObject -Class Win32_Product | Where-Object { 
        ($_.Name -match "(?i)Java(\(TM\))*\s\d+(\sUpdate\s\d+)*\s[(]64-bit[)]$") -or `
        (($_.Name -match "(?i)J2SE\sRuntime\sEnvironment\s\d[.]\d(\sUpdate\s\d+)*$") -and ($_.IdentifyingNumber -match "^\{64"))
    }
} else {
    $64bitJava += Get-WmiObject -Class Win32_Product | Where-Object { 
        $_.Name -match "(?i)Java((\(TM\) 7)|(\s\d+))(\sUpdate\s\d+)*\s[(]64-bit[)]$"
    }
}
 Write-Host("Finding Setup Files...")
#Install latest Java Version  
 Get-ChildItem -Path $PSScriptRoot -Filter *.exe | ForEach {
    $TempBit = (Test-is64Bit -FilePath $_.FullName.tostring()).FileType
    $SetupFiles.Add($_.Name,@{Version = $_.VersionInfo.ProductVersion;IntSize = $TempBit;FullPath=$_.Fullname;fsobject=$_})
}
If ($SetupFiles.count -gt 0 ) {
    $Install = $SetupFiles.Clone()
    #Remove all but the newest x86 installer
    #sort by Version and select newest
    $temp = ($SetupFiles.GetEnumerator() | Sort-Object -Descending {$_.Value.Version} | Where-Object {$_.value.IntSize -eq "x86"} | select -First 1).name
    #remove all but the newest
    $SetupFiles.GetEnumerator() | Where-Object {$_.value.IntSize -eq "x86" -and $_.name -ne $temp} | foreach { $Install.Remove($_.name)}
    #Remove all but the newest x64 installer
    #sort by Version and select newest
    $temp = ($SetupFiles.GetEnumerator() | Sort-Object -Descending {$_.Value.Version} | Where-Object {$_.value.IntSize -eq "x64"} | select -First 1).name
    #remove all but the newest
    $SetupFiles.GetEnumerator() | Where-Object {$_.value.IntSize -eq "x64" -and $_.name -ne $temp} | foreach { $Install.Remove($_.name)}
    #Test if we need to install latest version. 
    $tempVersion = $null
    $tempVersion = ($Install.GetEnumerator() | Where-Object {$_.value.IntSize -eq "x64"}).value.Version
    $temp = $null
    $temp = ($64bitJava | Where-Object {$_.Version -eq $tempVersion}).Name
    If ([string]::IsNullOrEmpty($temp)) 
    {
        ForEach ($EXE in $Install.Keys) {
            #install 
            if($Install.$EXE.IntSize -eq "x64" ) {
		        Write-Host ("Install: " + $EXE + "`n`t`t Version: `t" + $Install.$EXE.Version + "`n`t`t Bit: `t`t" + $Install.$EXE.IntSize + "`n`t`t FullPath: `t" + $Install.$EXE.FullPath)
                Start-Process -FilePath $Install.$EXE.FullPath -ArgumentList $InstallOptions -Wait -Passthru
            }

	    }
    }
    $tempVersion = $null
    $tempVersion = ($Install.GetEnumerator() | Where-Object {$_.value.IntSize -eq "x86"}).value.Version
    $temp = $null
    $temp = ($32bitJava | Where-Object {$_.Version -eq $tempVersion}).Name
    If ([string]::IsNullOrEmpty($temp)) 
    {
         ForEach ($EXE in $Install.Keys) {
            #install
            if($Install.$EXE.IntSize -eq "x86" ) {
		        Write-Host ("Install: " + $EXE + "`n`t`t Version: `t" + $Install.$EXE.Version + "`n`t`t Bit: `t`t" + $Install.$EXE.IntSize + "`n`t`t FullPath: `t" + $Install.$EXE.FullPath)
                Start-Process -FilePath $Install.$EXE.FullPath -ArgumentList $InstallOptions -Wait -Passthru
            }
	    }
	}
}

#Disable Java Update Tab and also Updates and Notifications
Write-Host("Writing Registry Keys...")
reg add "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v EnableJavaUpdate /t REG_DWORD /d 00000000 /f | Out-Null 
reg add "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v EnableAutoUpdateCheck /t REG_DWORD /d 00000000 /f | Out-Null 
reg add "HKLM\SOFTWARE\JavaSoft" /v SPONSORS /t REG_SZ /d DISABLE /f | Out-Null 
 
Write-Host ("Starting Uninstalling ...")
Foreach ($app in $32bitJava) {
    if ($app -ne $null)
    {
        # Remove all versions of Java, where the version does not match the newest version.
        if ($app.Version -ne ($Install.GetEnumerator() | Where-Object {$_.value.IntSize -eq "x86"}).value.Version) {
            $appGUID = $app.Properties["IdentifyingNumber"].Value.ToString()
            write-host "Uninstalling 32-bit version: " $app.Name
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/qn /norestart /x $($appGUID)" -Wait -Passthru
        }
    }
}
 
Foreach ($app in $64bitJava) {
    if ($app -ne $null)
    {
        # Remove all versions of Java, where the version does not match the newest version.
        if ($app.Version -ne ($Install.GetEnumerator() | Where-Object {$_.value.IntSize -eq "x64"}).value.Version) {
            $appGUID = $app.Properties["IdentifyingNumber"].Value.ToString()
            write-host "Uninstalling 64-bit version: " $app.Name
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/qn /norestart /x $($appGUID)" -Wait -Passthru
        }
    }
}
#Stop-Transcript logging
If (-Not [string]::IsNullOrEmpty($LogFile)) {
	Stop-Transcript
}
}