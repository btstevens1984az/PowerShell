# Purpose: Open-PCBuildControlConsole — Reusable PowerShell function libraries.
Function Open-PCBuildControlConsole {
<#
	NAME	: 	PCBuildControlConsole.ps1




	PREREQS	:	PowerShell 2.0

	Purpose : Consolidate PowerShell scripts into one UI.

    Audience: IT-Service Delivery - Desktop

    Release Notes: 
#>

############################ Start Functions
function CheckTempFolder{


#$pathToInstalledSoftware = "C:\temp\PCBuildAutomationConsole\InstalledSoftware\"
$pathToSerialNumbers = "c:\temp\PCBuildAutomationConsole\serialNumbers.txt"

if(!(Test-Path -Path $pathToSerialNumbers)) {


# if not, create the directories and file
#new-item -path c:\temp -name "PCBuildAutomationConsole" -type directory 
New-Item c:\temp\PCBuildAutomationConsole\ -ItemType directory -Force
new-item c:\temp\PCBuildAutomationConsole\serialNumbers.txt -ItemType file -Force



} #end if

} # end function


function SetPSWindowSize
	{
		$a = (Get-Host).UI.RawUI
		$b = $a.WindowSize
		$b.Width = 80
		$b.Height = 60
		$a.WindowSize = $b
	}
function MainMenu {
    clear
    write-host "#######################    PC BUILD AUTOMATION CONSOLE    ######################" -foregroundColor Cyan
    write-host "#################################   MAIN MENU  #################################" -foregroundColor Cyan
    Write-Host ''
	Write-Host "Single PC:" -foreground white
    Write-Host "1. Remove from AD & SCCM"
    Write-Host "2. Assign OU"   # 
    Write-Host "3. Sync AD Groups and OU"
    Write-Host "4. Run CHKDSK"
    Write-Host "5. Post-Imaging Task Schedule"
    Write-Host "6. List Installed Software"
    Write-Host ''
	Write-Host "Multiple PCs:" -foreground white
	Write-Host "7. Remove from AD & SCCM"
	Write-Host "8. Assign OU"
	Write-Host "9. Sync AD Groups & OU"
	Write-Host "10. Run CHKDSK"
	Write-Host "11. Post-Imaging Task Schedule"
	Write-Host "12. List Installed Software"
    Write-Host "Ctrl-C to Exit" -ForegroundColor Red
    Write-Host ""
}

function backToMainMenu {

Write-Host 'Press any key to return to MAIN MENU...' -ForegroundColor Red
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function SetSourceLog($LogFile)
	{
		$LogFile = $LogFile | % { $_ -Replace 'ps1','LOG' }
		return $LogFile
	}

function Pause
	{
		""
		Write-Host "Script is paused."
		Write-Host "Press any key to continue"
		Write-Host " or X-out to cancel" -foregroundcolor red
		$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	}
function GetMultiplPCs {
# Get multiple PC Names to run a script on them
start-process powershell \\81.127.212.165\share\Desktop\Scripts\beta\beta_Desktop.Automation.Console\Components\Get.Multiple.PC.Names\launchNotepad.ps1 -Wait | Out-Null}


##########################################################################################
################################### Main Script Logic ####################################
##########################################################################################
do {
	SetPSWindowSize
    try
	    {
	    import-module activedirectory
	    #Write-Host "AD Module Imported!"
	    }
	
    catch
	    {
	    write-host "AD Module import failed. Please install AD Users & Computers."
	    }

  [int]$userMenuChoice = 0
  while ( $userMenuChoice -lt 1 -or $userMenuChoice -gt 14) {
    MainMenu

    [int]$userMenuChoice = Read-Host "Select an option and press [enter]"
    clear
    switch ($userMenuChoice) {
      ############################### Selection 1. Remove from AD & SCCM
      1{
      function GetComputerName
	{
		$ComputerName = Read-Host
		$ComputerName = $ComputerName | % { $_ -replace "`r",'' }
		if ($ComputerName -eq '')
			{
				$ComputerName = $Env:COMPUTERNAME
			}
		return $ComputerName
	}

function ImportPSModule($Module)
	{
	try
		{
			Import-Module $Module
			''
			write-host "    $Module module loaded!" -foregroundcolor green
			''
		}
	catch
		{
			Write-Host
			Write-Host '    Not able to load $Module module.' -foregroundcolor red
			Write-Host
			Write-host '    Please verify the module is available.' -foregroundcolor red
			Write-Host
			Write-Host '    Press any key to EXIT...' -foregroundcolor yellow
			$x = $host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
			exit
		}
	}

function DeleteSCCMComputer($ComputerName)
	{
		$resID = Get-WmiObject `
			-computername $SCCMServer `
			-query "select resourceID from sms_r_system where name like `'$ComputerName`'" `
			-Namespace "root\sms\site_$sitename"
	
		switch ($resID.ResourceId -eq $null)
			{
			$True
				{
					Write-Host "Machine NOT found in SCCM: $ComputerName"
				}
	
			$False
				{
					$comp = [wmi]"\\$SCCMServer\root\sms\site_$($sitename):sms_r_system.resourceID=$($resID.ResourceId)"
					$comp.psbase.delete()
					Write-Host "Machine DELETED from SCCM: $ComputerName"
				}
			}
	}

function DeleteADComputer($ComputerName)
	{
		try
			{
				If (Get-ADComputer -Filter {Name -eq $ComputerName})
					{
						try
							{
								Remove-ADComputer -Identity $ComputerName -confirm:$false
								Write-Host "Machine DELETED from AD: $ComputerName"
							}
						catch
							{
								Write-Host "ERROR: Failed to delete machine from AD: $ComputerName"
							}
					}
				Else
					{
						Write-Host "Machine NOT found in AD: $ComputerName"
					}
			}
		catch
			{
			}
	}

# = = = = = = = = = = = = = = = = = = = = = = = =
#  formatting, logging functions
# = = = = = = = = = = = = = = = = = = = = = = = =

function Pause($Action)
	{
		''
		Write-Host "Press any key to $Action ..."
		$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	}

function SetPoSHWindowSize($LogFile)
	{
		$a = (Get-Host).UI.RawUI
		$b = $a.WindowSize
		$b.Width = 80
		$b.Height = 58
		$a.WindowSize = $b
	}

function SetSourceLog($LogFile)
	{
		$LogFile = $LogFile | % { $_ -Replace 'ps1','LOG' }
		return $LogFile
	}

#  script main

SetPoSHWindowSize

$LogFile = SetSourceLog($MyInvocation.MyCommand.Name)
Start-Transcript $LogFile -Append | Out-Null

$SCCMServer = 'KSMS390'
$sitename = 'KCP'

ImportPSModule('ActiveDirectory')

Write-Host 'Enter computer name and press [enter]'
''
$ComputerName = GetComputerName

DeleteSCCMComputer($ComputerName)
DeleteADComputer($ComputerName)

Pause('EXIT')

Stop-Transcript | Out-Null

      }
      ############################### Selection 2. Assign OU
      2{
      clear
$serialNumber = Read-Host "Please enter the serial number"
Get-ADComputer $serialNumber -Properties DistinguishedName | ft DistinguishedName
Start-Sleep -s 3
clear


$desiredOU = Read-Host "
LIST OF OUs 
____________________
1. Advertising 
2. Buying Office 
3. Distribution 
4. Exec 
5. Finance 
6. HR 
7. Interior Planning 
8. IS 
9. Kiosk 
10. Legal 
11. LP 
12. Operations 
13. Product Development
14. Purchasing 
15. Real Estate 
16. Store Administration 
17. Store Planning
_____________________

Select the number of the desired OU"


if ($desiredOU -eq "1")    {
        $target = 'OU=Advertising,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        
        get-adcomputer $serialNumber | Move-ADObject -TargetPath $target -Verbose
    } 
if ($desiredOU -eq "2")    {
        $target = 'OU=Buying Office,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        
        get-adcomputer $serialNumber | Move-ADObject -TargetPath $target -Verbose
    } 
if ($desiredOU -eq "3")    {
        $target = 'OU=Distribution,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        
        get-adcomputer $serialNumber | Move-ADObject -TargetPath $target -Verbose
    } 
if ($desiredOU -eq "4")    {
        $target = 'OU=Exec,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        
        get-adcomputer $serialNumber | Move-ADObject -TargetPath $target -Verbose
    } 
if ($desiredOU -eq "5")    {
        $target = 'OU=Finance,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        
        get-adcomputer $serialNumber | Move-ADObject -TargetPath $target -Verbose
    } 
if ($desiredOU -eq "6")    {
        $target = 'OU=HR,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        
        get-adcomputer $serialNumber | Move-ADObject -TargetPath $target -Verbose
    } 
if ($desiredOU -eq "7")    {
        $target = 'OU=Interior Planning,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        
        get-adcomputer $serialNumber | Move-ADObject -TargetPath $target -Verbose
    } 
if ($desiredOU -eq "8")    {
        $target = 'OU=IS,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        
        get-adcomputer $serialNumber | Move-ADObject -TargetPath $target -Verbose
    } 
if ($desiredOU -eq "9")    {
        $target = 'OU=Kiosk,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        
        get-adcomputer $serialNumber | Move-ADObject -TargetPath $target -Verbose
    } 
if ($desiredOU -eq "10")    {
        $target = 'OU=Legal,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        
        get-adcomputer $serialNumber | Move-ADObject -TargetPath $target -Verbose
    } 
if ($desiredOU -eq "11")    {
        $target = 'OU=LP,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        
        get-adcomputer $serialNumber | Move-ADObject -TargetPath $target -Verbose
    } 
if ($desiredOU -eq "12")    {
        $target = 'OU=Operations,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        
        get-adcomputer $serialNumber | Move-ADObject -TargetPath $target -Verbose
    } 
if ($desiredOU -eq "13")    {
        $target = 'OU=Product Development,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        
        get-adcomputer $serialNumber | Move-ADObject -TargetPath $target -Verbose
    } 
if ($desiredOU -eq "14")    {
        $target = 'OU=Purchasing,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        
        get-adcomputer $serialNumber | Move-ADObject -TargetPath $target -Verbose
    } 
if ($desiredOU -eq "15")    {
        $target = 'OU=Real Estate,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        
        get-adcomputer $serialNumber | Move-ADObject -TargetPath $target -Verbose
    } 
if ($desiredOU -eq "16")    {
        $target = 'OU=Store Administration ,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        
        get-adcomputer $serialNumber | Move-ADObject -TargetPath $target -Verbose
    } 
if ($desiredOU -eq "17")    {
        $target = 'OU=Store Planning,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        
        get-adcomputer $serialNumber | Move-ADObject -TargetPath $target -Verbose
    } 


Start-Sleep -s 3
clear
# print confirmation
Write-Host "Move completed successfully! See confirmation below " -ForegroundColor Green
Get-ADComputer $serialNumber
Write-Host ''

    backToMainMenu    
    }
      ############################### Selection 3. Sync AD groups and OU
      3{
      

function ImportPSModule($Value)
	{
		try
			{
				Import-Module $Value
				""
				Write-Host "    $Value Module Loaded!" -foregroundcolor green
				""
			}
		catch
			{
				""
				Write-Host "    Not able to load $Value module." -foregroundcolor red
				""
				Write-host "    Please verify you have module $Value installed." -foregroundcolor red
				""
				Write-Host "    Press any key to EXIT" -foregroundcolor yellow
				$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
				exit
			}
	}

function GetComputerName($Selection)
	{
		$ComputerName = Read-Host "Enter $Selection computer name and press [enter]"
		if ($ComputerName -eq "")
			{
				Write-Host "$Selection name is blank"
				Write-Host "Press any key to EXIT" -foregroundcolor "yellow"
				$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
				exit
			}
		return $ComputerName.ToUpper()
	}


function GetADGroups($ComputerName)
	{
		$ADGroups = (Get-ADComputer $ComputerName -properties memberof).memberof
		return $ADGroups
	}

function CleanADGroups($ADGroups)
	{
		$CleanGroups = $ADGroups `
			| % {$_ -replace "CN=",""}
		$CleanGroups = $CleanGroups `
			| % {$_ -replace ",OU=Buying Office,OU=Corporate,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com",""}
		$CleanGroups = $CleanGroups `
			| % {$_ -replace ",OU=SCCM,OU=Installs,OU=Corporate,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com",""}
		$CleanGroups = $CleanGroups `
			| % {$_ -replace ",OU=SMS,OU=Installs,OU=Corporate,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com",""}
		$CleanGroups = $CleanGroups `
			| % {$_ -replace ",OU=Group Policy,OU=Installs,OU=Corporate,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com",""}
		$CleanGroups = $CleanGroups | sort
		return $CleanGroups
	}

function GetADLocation($ComputerName)
	{
		$ADLocation = Get-ADComputer $ComputerName | % {$_.DistinguishedName}
		$ADLocation = $ADLocation | % {$_ -Replace "CN=$ComputerName,",""}
		return $ADLocation
	}


function MoveADLocation($ComputerName, $ADLocation)
	{
		try
			{
				''
				Get-ADComputer $ComputerName | Move-ADObject -TargetPath $ADLocation
				''
				Write-Host "Move: Success!" -foregroundcolor green
				''
			}
		catch
			{
				''
				Write-Host "Move: Failed!" -foregroundcolor red
				''
			}
	}

function AddToADGroup($ComputerName, $ADGroups)
	{
		foreach ($ADGroup in $ADGroups)
			{
				try
					{
						Add-ADGroupMember "$ADGroup" -members "$target$"
						''
						Write-Host "Add to $ADGroup : Success!" -foregroundcolor green
						''
					}
				catch
					{
						''
						Write-Host "Add to $ADGroup : Fail!" -foregroundcolor red
						Write-Host "(Could already be a member)"
						''
					}
			}
	}



#ImportPSModule('ActiveDirectory')

$Source = GetComputerName('SOURCE')
$Target = GetComputerName('TARGET')

$ADGroups = GetADGroups($Source)
$SourceGroups = CleanADGroups($ADGroups)

# $ADGroups = GetADGroups("$Target")
# $TargetGroups = CleanADGroups($ADGroups)

$ADLocation = GetADLocation($Source)
''
Write-Host "   Move $target to" -foregroundcolor yellow
''
$ADLocation
''
Write-Host '   and add to groups:' -foregroundcolor yellow
''
$SourceGroups
''
''
Pause

MoveADLocation $Target $ADLocation
AddToADGroup $Target $SourceGroups

Pause
backtomainmenu
      }  
      ############################### Selection 4. Run CHKSK
      4{
        $serialNumber = Read-Host "Serial Number "
        $disks = Get-WmiObject -ComputerName $serialNumber -Class Win32_LogicalDisk
        $disks[0].Chkdsk($True, $False, $False, $True, $True, $True)
        Write-Host ''
        Write-Host "The PC will be restarted and CHKDSK will be ran."
        Write-Host "Press any key to proceed and then return to Main Menu."


        $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Restart-Computer $serialNumber -Force -Verbose
      }
      ############################### Selection 5. Post Imaging Task Schedule
      5{
start-process powershell \\81.127.212.165\share\Desktop\Scripts\beta\beta_Desktop.Automation.Console\Components\PostImagingTaskSchedule\launchNotepad.ps1 -Wait | Out-Null
$serialNumbers = get-content 'C:\Temp\PCBuildAutomationConsole\serialNumbers.txt'
foreach ($serialNumber in $serialNumbers){

Invoke-Command -computername $serialNumber -scriptblock {

$policyChecks = 0
while ($policyChecks -le 9) {                    # total of 3 hours of time
        
        #Test Conditions
        if    ( ((Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\" | Select-Object PendingFileRenameOperations).PendingFileRenameOperations -eq $null) `
        -and ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\"  |  Select-Object RebootRequired).RebootRequired -eq $null) `
        -and ((Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending\") -eq $False) ) {
        Write-Host "PC is NOT Pending Reboot."
        $policyChecks++
        }


        #Action if the PC is pending reboot.
        else
        {
            Write-Host "PC is Pending Reboot."
            # Check if msiexec is running before issuing restart. Don't want to interrupt any currently running installs.
            $msiexec = Get-Process msiexec -ErrorAction SilentlyContinue
                if ($msiexec) {Write-Host "MSIEXEC is currently running. Restart cancelled for now."
                $policyChecks++
                
                }else{
                # msiexec is not running. restart pc.                  
                Restart-Computer 131.230.190.167 -verbose
                Start-Sleep -Seconds 600  # allow 10 mins for the pc to 'Configure Windows Updates' and restart. soooo many updates...
                $policyChecks++
            
            }
        }
    Start-Sleep -Seconds 1200 # set to check pending reboot every 20 mins
    }

} -AsJob




}
Start-job -ScriptBlock{
Start-Sleep -Seconds 30 # set to 3 hours
$serialNumbers = Get-Content 'c:\temp\PCBuildAutomationConsole\serialNumbers.txt'
foreach($serialNumber in $serialNumbers){
$pathToInstalledSoftware = "C:\temp\PCBuildAutomationConsole\InstalledSoftware\"

    # Check if path exists
    if(!(Test-Path -Path $pathToInstalledSoftware)) {
    # if not, create the directories
    new-item -path c:\temp -name "PCBuildAutomationConsole" -type directory 
    new-item -path c:\temp\PCBuildAutomationConsole -name "InstalledSoftware" -type directory
    }else{
    #new-item -path c:\temp\PCBuildAutomationConsole\InstalledSoftware -name "$serialNumber.txt" -type directory -Force
    # now get a list of installed software and write it to a file
    (get-wmiobject -class ‘Win32_Product’ -computer $serialNumber | Select-Object Name,Version | Sort-Object -Property Name | Out-File -Encoding unicode "c:\temp\PCBuildAutomationConsole\InstalledSoftware\$serialNumber.txt")

    # pop open the file with notepad
    #start-process powershell \\81.127.212.165\share\Desktop\Scripts\beta\beta_Desktop.Automation.Console\Components\PostImagingTaskSchedule\launchNotepad.ps1 -Wait | Out-Null
    start-process notepad "c:\temp\PCBuildAutomationConsole\InstalledSoftware\$serialNumber.txt"
    }

}


}

      
}
      ############################### Selection 6. List Installed Software
      6{
$serialNumber = Read-Host "Serial Number "
get-wmiobject -class ‘Win32_Product’ -computer $serialNumber | Select-Object Name,Version | Sort-Object -Property Name


backtoMainMenu
      
      
      }
      
      #################Multiple PCs Section#################################################################
      ############################### Selection 7. Remove from AD & SCCM
      7{
      
# Get multiple PC Names and run a script on them
start-process powershell \\81.127.212.165\share\Desktop\Scripts\beta\beta_Desktop.Automation.Console\Components\Multiple.PC.Names\launchNotepad.ps1 -Wait | Out-Null

function SetSourceLog($LogFile)
	{
		$LogFile = $LogFile | % { $_ -Replace 'ps1','LOG' }
		return $LogFile
	}

function SetPoSHWindowSize
	{
		$a = (Get-Host).UI.RawUI
		$b = $a.WindowSize
		$b.Width = 80
		$b.Height = 58
		$a.WindowSize = $b
	}

function ImportPSModule($Module)
	{
	try
		{
			Import-Module $Module
			write-host
			write-host "    $Module module loaded!" -foregroundcolor "green"
			write-host
		}
	catch
		{
			Write-Host
			Write-Host "    Not able to load $Module module." -foregroundcolor "red"
			Write-Host
			Write-host "    Please verify the module is available." -foregroundcolor "red"
			Write-Host
			Write-Host "    Press any key to EXIT" -foregroundcolor "yellow"
			$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
			exit
		}
	}

function DeleteSCCMComputer($ComputerName)
	{
		$resID = Get-WmiObject `
			-computername $SCCMServer `
			-query "select resourceID from sms_r_system where name like `'$ComputerName`'" `
			-Namespace "root\sms\site_$sitename"
	
		switch ($resID.ResourceId -eq $null)
			{
			$True
				{
					Write-Host "Machine NOT found in SCCM: $ComputerName"
				}
	
			$False
				{
					$comp = [wmi]"\\$SCCMServer\root\sms\site_$($sitename):sms_r_system.resourceID=$($resID.ResourceId)"
					$comp.psbase.delete()
					Write-Host "Machine DELETED from SCCM: $ComputerName"
				}
			}
	}

function DeleteADComputer($ComputerName)
	{
		try
			{
				If (Get-ADComputer -Filter {Name -eq $ComputerName})
					{
						try
							{
								Remove-ADComputer -Identity $ComputerName -confirm:$false
								Write-Host "Machine DELETED from AD: $ComputerName"
							}
						catch
							{
								Write-Host "ERROR: Failed to delete machine from AD: $ComputerName"
							}
					}
				Else
					{
						Write-Host "Machine NOT found in AD: $ComputerName"
					}
			}
		catch
			{
			}
	}

function Pause($Action)
	{
		''
		Write-Host "Press any key to $Action ..."
		$x = $host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
	}

SetPoSHWindowSize

#$LogFile = SetSourceLog($MyInvocation.MyCommand.Name)
#Start-Transcript $LogFile | Out-Null

$SCCMServer = 'KSMS390'
$sitename = 'KCP'

#ImportPSModule('ActiveDirectory')

$Computers = Get-Content 'C:\temp\serialnumbers.txt'
''
Write-Host 'Computer list to remove:'
''
Write-Host '===================================='
$Computers
Write-Host '===================================='
Pause('CONTINUE')

foreach ($ComputerName in $Computers)
	{
		DeleteSCCMComputer($ComputerName)
		DeleteADComputer($ComputerName)
	}

#Stop-Transcript | Out-Null
backtoMainMenu     
      }
      ############################### Selection 8. Assign OU
      8{
# Get multiple PC Names and run a script on them
start-process powershell \\81.127.212.165\share\Desktop\Scripts\beta\beta_Desktop.Automation.Console\Components\Multiple.PC.Names\launchNotepad.ps1 -Wait | Out-Null

$desiredOU = Read-Host "
LIST OF OUs 
____________________
1. Advertising 
2. Buying Office 
3. Distribution 
4. Exec 
5. Finance 
6. HR 
7. Interior Planning 
8. IS 
9. Kiosk 
10. Legal 
11. LP 
12. Operations 
13. Product Development
14. Purchasing 
15. Real Estate 
16. Store Administration 
17. Store Planning
_____________________

Select the number of the desired OU "


if ($desiredOU -eq "1")    {
        $target = 'OU=Advertising,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        $serialNumbers = get-content 'C:\Temp\serialNumbers.txt'
        foreach ($i in $serialNumbers){get-adcomputer $i | Move-ADObject -TargetPath $target -Verbose}
    }
if ($desiredOU -eq "2")    {
        $target = 'OU=Buying Office,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        $serialNumbers = get-content 'C:\Temp\serialNumbers.txt'
        foreach ($i in $serialNumbers){get-adcomputer $i | Move-ADObject -TargetPath $target -Verbose}
    } 
if ($desiredOU -eq "3")    {
        $target = 'OU=Distribution,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        $serialNumbers = get-content 'C:\Temp\serialNumbers.txt'
        foreach ($i in $serialNumbers){get-adcomputer $i | Move-ADObject -TargetPath $target -Verbose}
    } 
if ($desiredOU -eq "4")    {
        $target = 'OU=Exec,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        $serialNumbers = get-content 'C:\Temp\serialNumbers.txt'
        foreach ($i in $serialNumbers){get-adcomputer $i | Move-ADObject -TargetPath $target -Verbose}
    } 
if ($desiredOU -eq "5")    {
        $target = 'OU=Finance,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        $serialNumbers = get-content 'C:\Temp\serialNumbers.txt'
        foreach ($i in $serialNumbers){get-adcomputer $i | Move-ADObject -TargetPath $target -Verbose}
    } 
if ($desiredOU -eq "6")    {
        $target = 'OU=HR,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        $serialNumbers = get-content 'C:\Temp\serialNumbers.txt'
        foreach ($i in $serialNumbers){get-adcomputer $i | Move-ADObject -TargetPath $target -Verbose}
    } 
if ($desiredOU -eq "7")    {
        $target = 'OU=Interior Planning,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        $serialNumbers = get-content 'C:\Temp\serialNumbers.txt'
        foreach ($i in $serialNumbers){get-adcomputer $i | Move-ADObject -TargetPath $target -Verbose}
    } 
if ($desiredOU -eq "8")    {
        $target = 'OU=IS,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        $serialNumbers = get-content 'C:\Temp\serialNumbers.txt'
        foreach ($i in $serialNumbers){get-adcomputer $i | Move-ADObject -TargetPath $target -Verbose}
    } 
if ($desiredOU -eq "9")    {
        $target = 'OU=Kiosk,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        $serialNumbers = get-content 'C:\Temp\serialNumbers.txt'
        foreach ($i in $serialNumbers){get-adcomputer $i | Move-ADObject -TargetPath $target -Verbose}
    } 
if ($desiredOU -eq "10")    {
        $target = 'OU=Legal,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        $serialNumbers = get-content 'C:\Temp\serialNumbers.txt'
        foreach ($i in $serialNumbers){get-adcomputer $i | Move-ADObject -TargetPath $target -Verbose}
    } 
if ($desiredOU -eq "11")    {
        $target = 'OU=LP,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        $serialNumbers = get-content 'C:\Temp\serialNumbers.txt'
        foreach ($i in $serialNumbers){get-adcomputer $i | Move-ADObject -TargetPath $target -Verbose}
    } 
if ($desiredOU -eq "12")    {
        $target = 'OU=Operations,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        $serialNumbers = get-content 'C:\Temp\serialNumbers.txt'
        foreach ($i in $serialNumbers){get-adcomputer $i | Move-ADObject -TargetPath $target -Verbose}
    } 
if ($desiredOU -eq "13")    {
        $target = 'OU=Product Development,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        $serialNumbers = get-content 'C:\Temp\serialNumbers.txt'
        foreach ($i in $serialNumbers){get-adcomputer $i | Move-ADObject -TargetPath $target -Verbose}
    } 
if ($desiredOU -eq "14")    {
        $target = 'OU=Purchasing,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        $serialNumbers = get-content 'C:\Temp\serialNumbers.txt'
        foreach ($i in $serialNumbers){get-adcomputer $i | Move-ADObject -TargetPath $target -Verbose}
    } 
if ($desiredOU -eq "15")    {
        $target = 'OU=Real Estate,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        $serialNumbers = get-content 'C:\Temp\serialNumbers.txt'
        foreach ($i in $serialNumbers){get-adcomputer $i | Move-ADObject -TargetPath $target -Verbose}
    } 
if ($desiredOU -eq "16")    {
        $target = 'OU=Store Administration ,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        $serialNumbers = get-content 'C:\Temp\serialNumbers.txt'
        foreach ($i in $serialNumbers){get-adcomputer $i | Move-ADObject -TargetPath $target -Verbose}
    } 
if ($desiredOU -eq "17")    {
        $target = 'OU=Store Planning,OU=Corporate,OU=Workstations,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com'
        $serialNumbers = get-content 'C:\Temp\serialNumbers.txt'
        foreach ($i in $serialNumbers){get-adcomputer $i | Move-ADObject -TargetPath $target -Verbose}
    } 


Start-Sleep -s 3
clear
# print confirmation
Write-Host "Move completed successfully! See confirmation below " -ForegroundColor Green
foreach ($i in $serialNumbers){Get-ADComputer $i}
Write-Host ''
backToMainMenu 
    
      
      }
      ############################### Selection 9. Sync AD Groups & OU
      9{
function GetComputerName($Selection)
	{
		$ComputerName = Read-Host "Enter $Selection computer name and press [enter]"
		if ($ComputerName -eq "")
			{
				Write-Host "$Selection name is blank"
				Write-Host "Press any key to EXIT" -foregroundcolor "yellow"
				$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
				exit
			}
		return $ComputerName.ToUpper()
	}


function GetADGroups($ComputerName)
	{
		$ADGroups = (Get-ADComputer $ComputerName -properties memberof).memberof
		return $ADGroups
	}

function CleanADGroups($ADGroups)
	{
		$CleanGroups = $ADGroups `
			| % {$_ -replace "CN=",""}
		$CleanGroups = $CleanGroups `
			| % {$_ -replace ",OU=Buying Office,OU=Corporate,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com",""}
		$CleanGroups = $CleanGroups `
			| % {$_ -replace ",OU=SCCM,OU=Installs,OU=Corporate,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com",""}
		$CleanGroups = $CleanGroups `
			| % {$_ -replace ",OU=SMS,OU=Installs,OU=Corporate,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com",""}
		$CleanGroups = $CleanGroups `
			| % {$_ -replace ",OU=Group Policy,OU=Installs,OU=Corporate,OU=Kohls,DC=cp,DC=ad,DC=kohls,DC=com",""}
		$CleanGroups = $CleanGroups | sort
		return $CleanGroups
	}

function GetADLocation($ComputerName)
	{
		$ADLocation = Get-ADComputer $ComputerName | % {$_.DistinguishedName}
		$ADLocation = $ADLocation | % {$_ -Replace "CN=$ComputerName,",""}
		return $ADLocation
	}


function MoveADLocation($ComputerName, $ADLocation)
	{
		try
			{
				''
				Get-ADComputer $ComputerName | Move-ADObject -TargetPath $ADLocation
				''
				Write-Host "Move: Success!" -foregroundcolor green
				''
			}
		catch
			{
				''
				Write-Host "Move: Failed!" -foregroundcolor red
				''
			}
	}

function AddToADGroup($ComputerName, $ADGroups)
	{
		foreach ($ADGroup in $ADGroups)
			{
				try
					{
						Add-ADGroupMember "$ADGroup" -members "$target$"
						''
						Write-Host "Add to $ADGroup : Success!" -foregroundcolor green
						''
					}
				catch
					{
						''
						Write-Host "Add to $ADGroup : Fail!" -foregroundcolor red
						Write-Host "(Could already be a member)"
						''
					}
			}
	}



#ImportPSModule('ActiveDirectory')



$Source = Read-Host "Serial number of source PC"
Write-Host "Please enter serial number of target PCs in the text file that pops open. Then close the window."
start-process powershell \\81.127.212.165\share\Desktop\Scripts\beta\beta_Desktop.Automation.Console\components\Multiple.PC.InstalledSoftware\LaunchNotepad.ps1 -Wait | Out-Null
$Targets = Get-Content 'c:\temp\PCBuildAutomationConsole\serialNumbers.txt'


    $ADGroups = GetADGroups($Source)
    $ADLocation = GetADLocation($Source)

    <#
    ''
    Write-Host "   Move $target to" -foregroundcolor yellow
    ''
    $ADLocation
    ''
    Write-Host '   and add to groups:' -foregroundcolor yellow
    ''
    $SourceGroups
    ''
    ''
    Pause
    #>

foreach($target in $Targets){

    MoveADLocation $Target $ADLocation
    AddToADGroup $Target $ADGroups

    
}

backtomainmenu
      
}
      ############################### Selection 10. Run CHKDSK
      10{Write-Host "Run CHKDSK"}
      ############################### Selection 11. Post-Imaging Task Schedule
      11.{

CheckTempFolder
start-process powershell \\81.127.212.165\share\Desktop\Scripts\beta\beta_Desktop.Automation.Console\Components\PostImagingTaskSchedule\launchNotepad.ps1 -Wait | Out-Null
$serialNumbers = get-content 'C:\Temp\PCBuildAutomationConsole\serialNumbers.txt'
foreach ($serialNumber in $serialNumbers){

Invoke-Command -computername $serialNumber -scriptblock {

$policyChecks = 0
while ($policyChecks -le 9) {                    # total of 3 hours of time
        
        #Test Conditions
        if    ( ((Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\" | Select-Object PendingFileRenameOperations).PendingFileRenameOperations -eq $null) `
        -and ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\"  |  Select-Object RebootRequired).RebootRequired -eq $null) `
        -and ((Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending\") -eq $False) ) {
        Write-Host "PC is NOT Pending Reboot."
        $policyChecks++
        }


        #Action if the PC is pending reboot.
        else
        {
            Write-Host "PC is Pending Reboot."
            # Check if msiexec is running before issuing restart. Don't want to interrupt any currently running installs. Also, get machine policy while we
            $msiexec = Get-Process msiexec -ErrorAction SilentlyContinue
                if ($msiexec) {Write-Host "MSIEXEC is currently running. Restart cancelled for now."
                $policyChecks++
                Write-Host "Initiating Machine Policy Retrieval"
                Invoke-WmiMethod -Namespace root\ccm -Class sms_client -Name TriggerSchedule "{00000000-0000-0000-0000-000000000021}"
                }else{
                # msiexec is not running. restart pc.                  
                Restart-Computer 131.230.190.167 -verbose
                Start-Sleep -Seconds 600  # allow 10 mins for the pc to 'Configure Windows Updates' and restart. soooo many updates...
                $policyChecks++
            
            }
        }
    Start-Sleep -Seconds 1200 # set to check pending reboot every 20 mins
    }

} -AsJob # end invoke-command


} # end foreach


Start-job -ScriptBlock{
Start-Sleep -Seconds 10800 # set to 3 hours
$serialNumbers = Get-Content 'c:\temp\PCBuildAutomationConsole\serialNumbers.txt'
foreach($serialNumber in $serialNumbers){
$pathToInstalledSoftware = "C:\temp\PCBuildAutomationConsole\InstalledSoftware\"

    # Check if path exists
    if(!(Test-Path -Path $pathToInstalledSoftware)) {
    # if not, create the directories
    new-item -path c:\temp -name "PCBuildAutomationConsole" -type directory 
    new-item -path c:\temp\PCBuildAutomationConsole -name "InstalledSoftware" -type directory
    }else{
    #new-item -path c:\temp\PCBuildAutomationConsole\InstalledSoftware -name "$serialNumber.txt" -type directory -Force
    # now get a list of installed software and write it to a file
    (get-wmiobject -class ‘Win32_Product’ -computer $serialNumber | Select-Object Name,Version | Sort-Object -Property Name | Out-File -Encoding unicode "c:\temp\PCBuildAutomationConsole\InstalledSoftware\$serialNumber.txt")

    # pop open the file with notepad
    #start-process powershell \\81.127.212.165\share\Desktop\Scripts\beta\beta_Desktop.Automation.Console\Components\PostImagingTaskSchedule\launchNotepad.ps1 -Wait | Out-Null
    start-process notepad "c:\temp\PCBuildAutomationConsole\InstalledSoftware\$serialNumber.txt"
    }

} # end foreach
} # end scriptblock 
} # end section 11
      ############################### Selection 12. List Installed Software
      12{
# Get multiple PC Names and run a script on them
clear
Write-Host "Please scan in the serial numbers into serialNumbers.txt. When all"
write-host "serial numbers have been added, close notepad and wait a few minutes."
Write-Host "Notepad will open a separate text file with a list of installed software"
Write-Host "per serial number."
start-process powershell \\81.127.212.165\share\Desktop\Scripts\beta\beta_Desktop.Automation.Console\components\Multiple.PC.InstalledSoftware\LaunchNotepad.ps1 -Wait | Out-Null
$serialNumbers = Get-Content 'c:\temp\PCBuildAutomationConsole\serialNumbers.txt'


foreach($serialNumber in $serialNumbers){
    $pathToInstalledSoftware = "C:\temp\PCBuildAutomationConsole\InstalledSoftware\"

    # Check if path exists
    if(!(Test-Path -Path $pathToInstalledSoftware)) {
    # if not, create the directories
    new-item -path c:\temp -name "PCBuildAutomationConsole" -type directory 
    new-item -path c:\temp\PCBuildAutomationConsole -name "InstalledSoftware" -type directory
    }else{
    #new-item -path c:\temp\PCBuildAutomationConsole\InstalledSoftware -name "$serialNumber.txt" -type directory -Force
    # now get a list of installed software and write it to a file
    (get-wmiobject -class ‘Win32_Product’ -computer $serialNumber | Select-Object Name,Version | Sort-Object -Property Name | Out-File -Encoding unicode "c:\temp\PCBuildAutomationConsole\InstalledSoftware\$serialNumber.txt")

    # pop open the file with notepad
    notepad c:\temp\PCBuildAutomationConsole\InstalledSoftware\$serialNumber.txt
    }

}  
clear
Write-Host "Process completed successfully." -ForegroundColor Green
Write-Host "Notepad has opened a separate text file with a list of installed software"
write-host "per serial number. Please verify that all software requested in the"
write-host "PC Build Request is installed. Also, verify that Check Point Endpoint Security"
write-host "and Cisco Anyconnect Secure Mobility Client have installed as well."
Write-Host ''   
      
backtoMainMenu  
      
}

      default {Write-Host "Please select one of the choices."}
    }
  
  }
} while ( $userMenuChoice -ne 14 )
}