<#
.SYNOPSIS
	Monitor when USB is inserted and removed.
.DESCRIPTION
	The script ran in task sechduler on system startup. It monitors a USB letter and Name
	If USB removal event is triggered it will shut down the system. 
	All events are logged
.LINK 
	https://github.com/PowerShellCrack/USBStatus/edit/master/Detect-USBStatus.ps1
#>
##*===============================================
##* VARIABLE DECLARATION
##*===============================================
[string]$TaskName = "Monitor USB Boot Key - System Startup"
[string]$USBLetter = "I:"
[string]$USBName = "BOOTKEY"
##*===============================================
##* Do not modify section below
$t = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);'
add-type -name win -member $t -namespace native
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0)

## Variables: Permissions/Accounts
[Security.Principal.WindowsIdentity]$CurrentProcessToken = [Security.Principal.WindowsIdentity]::GetCurrent()
[Security.Principal.SecurityIdentifier]$CurrentProcessSID = $CurrentProcessToken.User
[string]$ProcessNTAccount = $CurrentProcessToken.Name
[string]$ProcessNTAccountSID = $CurrentProcessSID.Value
[boolean]$IsAdmin = [boolean]($CurrentProcessToken.Groups -contains [Security.Principal.SecurityIdentifier]'S-1-5-32-544')
[boolean]$IsLocalSystemAccount = $CurrentProcessSID.IsWellKnown([Security.Principal.WellKnownSidType]'LocalSystemSid')
[boolean]$IsLocalServiceAccount = $CurrentProcessSID.IsWellKnown([Security.Principal.WellKnownSidType]'LocalServiceSid')
[boolean]$IsNetworkServiceAccount = $CurrentProcessSID.IsWellKnown([Security.Principal.WellKnownSidType]'NetworkServiceSid')
[boolean]$IsServiceAccount = [boolean]($CurrentProcessToken.Groups -contains [Security.Principal.SecurityIdentifier]'S-1-5-6')
[boolean]$IsProcessUserInteractive = [Environment]::UserInteractive
[string]$LocalSystemNTAccount = (New-Object -TypeName 'System.Security.Principal.SecurityIdentifier' -ArgumentList ([Security.Principal.WellKnownSidType]::'LocalSystemSid', $null)).Translate([Security.Principal.NTAccount]).Value

#  Check if script is running in session zero
If ($IsLocalSystemAccount -or $IsLocalServiceAccount -or $IsNetworkServiceAccount -or $IsServiceAccount) { $SessionZero = $true } Else { $SessionZero = $false }

##*===============================================
##* PATH VARIABLE DECLARATION
##*===============================================
## Variables: Script Name and Script Paths
[string]$scriptPath = $MyInvocation.MyCommand.Definition
[string]$scriptDirectory = Split-Path -Path $scriptPath -Parent

$RunningDate = Get-Date -Format MMddyyyy
If ($SessionZero) {
    $FinalLogFileName = ($ScriptName.Trim(" ") + "(SYSTEM)-" + $RunningDate)
} Else {
    $FinalLogFileName = ($ScriptName.Trim(" ") + "(" + $env:USERNAME + ")-" + $RunningDate)
}
[string]$Logfile = "$scriptDirectory\Logs\$FinalLogFileName.log"

##*===============================================
##* FUNCTIONS
##*===============================================
Function Write-Log{
    [CmdletBinding()]
    Param (
        [string]$logstring,
        [switch]$writehost = $false 
    )
    Add-content $Logfile -value $logstring
    If($writehost){
        Write-Host $logstring
    }
}

#https://powershell.org/2013/04/29/powershell-popup/
Function Show-PopUp{ 
<# 
        .SYNOPSIS 
            Creates a Timed Message Popup Dialog Box. 
        .DESCRIPTION 
            Creates a Timed Message Popup Dialog Box. 
        .OUTPUTS 
            The Value of the Button Selected or -1 if the Popup Times Out. 
            Values: 
                -1 Timeout   
                    1  OK 
                    2  Cancel 
                    3  Abort 
                    4  Retry 
                    5  Ignore 
                    6  Yes 
                    7  No 
        .PARAMETER Message 
            [string] The Message to display. 
        .PARAMETER Title 
            [string] The MessageBox Title. 
        .PARAMETER TimeOut 
            [int]   The Timeout Value of the MessageBox in seconds.  
                    The Default is 0 - No Timeout. 
        .PARAMETER ButtonSet 
            [string] The Buttons to be Displayed in the MessageBox.  
 
                        Values: 
                        Value     Buttons 
                        OK        OK                   - This is the Default           
                        OC        OK Cancel           
                        AIR       Abort Ignore Retry 
                        YNC       Yes No Cancel      
                        YN        Yes No              
                        RC        Retry Cancel        
        .PARAMETER IconType 
            [string] The Icon to be Displayed in the MessageBox.  
 
                        Values: 
                        None      - This is the Default 
                        Critical     
                        Question     
                        Exclamation  
                        Information  
        .EXAMPLE 
            $RetVal = Show-PopUp -Message "Data Trucking Company" -Title "Popup Test" -TimeOut 5 -ButtonSet YNC -Icon Exclamation 
 
            FunctionName : Show-PopUp 
 
        .LINK 
             
        #> 
    [CmdletBinding()][OutputType([int])]Param( 
        [parameter(Mandatory=$true, ValueFromPipeLine=$true)][Alias("Msg")][string]$Message, 
        [parameter(Mandatory=$false, ValueFromPipeLine=$false)][Alias("Ttl")][string]$Title = $null, 
        [parameter(Mandatory=$false, ValueFromPipeLine=$false)][Alias("Duration")][int]$TimeOut = 0, 
        [parameter(Mandatory=$false, ValueFromPipeLine=$false)][Alias("But","BS")][ValidateSet( "OK", "OC", "AIR", "YNC" , "YN" , "RC")][string]$ButtonSet = "OK", 
        [parameter(Mandatory=$false, ValueFromPipeLine=$false)][Alias("ICO")][ValidateSet( "None", "Critical", "Question", "Exclamation" , "Information" )][string]$IconType = "None" 
            ) 
     
    $ButtonSets = "OK", "OC", "AIR", "YNC" , "YN" , "RC" 
    $IconTypes  = "None", "Critical", "Question", "Exclamation" , "Information" 
    $IconVals = 0,16,32,48,64 
    if((Get-Host).Version.Major -ge 3){ 
        $Button   = $ButtonSets.IndexOf($ButtonSet) 
        $Icon     = $IconVals[$IconTypes.IndexOf($IconType)] 
        } 
    else{ 
        $ButtonSets|ForEach-Object -Begin{$Button = 0;$idx=0} -Process{ if($_.Equals($ButtonSet)){$Button = $idx           };$idx++ } 
        $IconTypes |ForEach-Object -Begin{$Icon   = 0;$idx=0} -Process{ if($_.Equals($IconType) ){$Icon   = $IconVals[$idx]};$idx++ } 
        } 
    $objShell = New-Object -com "Wscript.Shell" 
    $objShell.Popup($Message,$TimeOut,$Title,$Button+$Icon)
}

Function Get-ScheduledTasks{
    [CmdletBinding()]
    Param (
        [string]$computername
    )
    $path = "\\" + $computername + "\c$\Windows\System32\Tasks"
    $tasks = Get-ChildItem -Path $path -File

    if ($tasks)
    {
        Write-Verbose -Message "I found $($tasks.count) tasks for $computername"
    }

    foreach ($item in $tasks)
    {
        $AbsolutePath = $path + "\" + $item.Name
        $task = [xml] (Get-Content $AbsolutePath)
        [STRING]$check = $task.Task.Principals.Principal.UserId

        if ($task.Task.Principals.Principal.UserId)
        {
          Write-Verbose -Message "Writing the log file with values for $computername"           
          Add-content -path $logfilepath -Value "$computername,$item,$check"
        }

    }

}
##*===============================================
##* MAIN
##*===============================================
$RunningTasks = Get-ScheduledTask -TaskName $TaskName
If (!$SessionZero -and $RunningTasks.State -eq "Running"){
    Stop-ScheduledTask -TaskName $TaskName
    taskkill /IM powershell.exe /FI "USERNAME eq SYSTEM"
}
Unregister-Event -SourceIdentifier volumeChange -ErrorAction SilentlyContinue

Register-WmiEvent -Class win32_VolumeChangeEvent -SourceIdentifier volumeChange
Write-Log ((get-date -format s) +"     Beginning $ScriptName...") -writehost
do{
    $newEvent = Wait-Event -SourceIdentifier volumeChange
    $eventType = $newEvent.SourceEventArgs.NewEvent.EventType
    $eventTypeName = switch($eventType){
        1 {"Configuration changed"}
        2 {"Device arrival"}
        3 {"Device removal"}
        4 {"docking"}
    }

    #Write-Log ((get-date -format s) +"     Event detected = "+ $eventTypeName) -writehost
    if ($eventType -eq 2){
        Write-Log ((get-date -format s) +"     USB Key arrival event detected, getting USB details...") -writehost
        $driveLetter = $newEvent.SourceEventArgs.NewEvent.DriveName
        $driveLabel = ([wmi]"Win32_LogicalDisk='$driveLetter'").VolumeName
        Write-Log ((get-date -format s) +"     Drive name = "+ $driveLetter) -writehost
        Write-Log ((get-date -format s) +"     Drive label = "+ $driveLabel) -writehost
        # Execute process if drive matches specified condition(s)
        if ( ($driveLetter -eq $USBLetter) -and ($driveLabel -eq $USBName) ){
            Write-Log ((get-date -format s) +"     Starting task in 3 seconds...") -writehost
            #Stop-Computer 10.199.208.191  $env:COMPUTERNAME -force
            #start-process "Z:\sync.bat"
        }
    } 
    ElseIf ($eventType -eq 3){
        $driveLetter = $newEvent.SourceEventArgs.NewEvent.DriveName
        if ($driveLetter -eq $USBLetter){
            If ($SessionZero) {
                Write-Log ((get-date -format s) +"     USB Key removal event detected, rebooting system...") -writehost
                Stop-Computer 10.199.208.191 $env:COMPUTERNAME -Force
            } Else{
                Write-Log ((get-date -format s) +"     USB Key removal event detected, sending message...") -writehost
                $result = Show-PopUp -Message USB Key ($driveLetter) was removed`n`nSystem shutdown will be triggered in 30 seconds, Continue? -Title  USB Key removal -TimeOut 30 -ButtonSet "OC" -IconType "Exclamation"
                
		If ($result -eq 1){ # Accepted
                    Write-Log ((get-date -format s) +"     User accepted, Shutting down system...") -writehost
                    Stop-Computer 10.199.208.191 $env:COMPUTERNAME -force
                } 
		ElseIf($result -eq 2){ # Cancelled
                    Write-Log ((get-date -format s) +"     User cancelled system shutdown...") -writehost
                } 
		Else { #Let message continue
                    Write-Log ((get-date -format s) +"     Countdown ended, Shutting down system...") -writehost
                    Stop-Computer 10.199.208.191 $env:COMPUTERNAME -force
                } 
            }          
        }
    }
    Remove-Event -SourceIdentifier volumeChange
} 
while (1 -eq 1) #Loop until next event
Unregister-Event -SourceIdentifier volumeChange