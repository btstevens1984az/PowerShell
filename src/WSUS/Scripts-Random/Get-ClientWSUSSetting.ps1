# Purpose: Get-ClientWSUSSetting — Windows Server Update Services administration.
﻿Function Get-ClientWSUSSetting {
    <#  
    .SYNOPSIS  
        Retrieves the WSUS client settings on a local or remove system.

    .DESCRIPTION
        Retrieves the WSUS client settings on a local or remove system.
         
    .PARAMETER Computername
        Name of computer to connect to. Can be a collection of computers.

    .PARAMETER ShowEnvironment
        Display only the Environment settings.

    .PARAMETER ShowConfiguration
        Display only the Configuration settings.

        Name: Get-WSUSClient
               
    .LINK  
        https://learn-powershell.net
        
    .EXAMPLE
    Get-ClientWSUSSetting -Computername 157.154.251.126
    
    RescheduleWaitTime            : NA
    AutoInstallMinorUpdates       : NA
    TargetGroupEnabled            : NA
    ScheduledInstallDay           : NA
    DetectionFrequencyEnabled     : 1
    Computername                  : TestServer
    RebootWarningTimeoutEnabled   : NA
    ElevateNonAdmins              : NA
    ScheduledInstallTime          : NA
    RebootRelaunchTimeout         : 10
    ScheduleInstallDay            : NA
    RescheduleWaitTimeEnabled     : NA
    DisableWindowsUpdateAccess    : NA
    AUOptions                     : 3
    DetectionFrequency            : 4
    RebootWarningTimeout          : NA
    ScheduleInstallTime           : NA
    TargetGroup                   : NA
    RebootRelaunchTimeoutEnabled  : 1
    UseWUServer                   : 1
    NoAutoRebootWithLoggedOnUsers : 1

    Description
    -----------
    Displays both Environment and Configuration settings for TestServer
    
    .EXAMPLE
    Get-ClientWSUSSetting -Computername 216.168.202.140 -ShowEnvironment
    
    Computername               : Server1
    TargetGroupEnabled         : NA
    TargetGroup                : NA
    DisableWindowsUpdateAccess : 1
    ElevateNonAdmins           : 0
    
    Description
    -----------
    Displays the Environment settings for Server1
    
    .Example
    Get-ClientWSUSSetting -Computername 216.168.202.140 -ShowConfiguration
    
    ScheduledInstallTime          : NA
    AutoInstallMinorUpdates       : 0
    ScheduledInstallDay           : NA
    Computername                  : Server1
    RebootWarningTimeoutEnabled   : NA
    RebootWarningTimeout          : NA
    NoAUAsDefaultShutdownOption   : NA
    RebootRelaunchTimeout         : NA
    DetectionFrequency            : 4
    ScheduleInstallDay            : NA
    RescheduleWaitTime            : NA
    RescheduleWaitTimeEnabled     : 0
    AUOptions                     : 3
    NoAutoRebootWithLoggedOnUsers : 1
    DetectionFrequencyEnabled     : 1
    ScheduleInstallTime           : NA
    NoAUShutdownOption            : NA
    RebootRelaunchTimeoutEnabled  : NA
    UseWUServer                   : 1
    IncludeRecommendedUpdates     : NA  
    
    Description
    -----------
    Displays the Configuration settings for Server1
    #>
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeLine = $True)]
        [string[]]$Computername = $Env:Computername,
        [parameter()]
        [switch]$ShowEnvironment,
        [parameter()]
        [switch]$ShowConfiguration        
    )
    Begin {
        $EnvKeys = "WUServer","WUStatusServer","ElevateNonAdmins","TargetGroupEnabled","TargetGroup","DisableWindowsUpdateAccess"
        $ConfigKeys = "AUOptions","AutoInstallMinorUpdates","DetectionFrequency","DetectionFrequencyEnabled","NoAutoRebootWithLoggedOnUsers",
        "NoAutoUpdate","RebootRelaunchTimeout","RebootRelaunchTimeoutEnabled","RebootWarningTimeout","RebootWarningTimeoutEnabled","RescheduleWaitTime","RescheduleWaitTimeEnabled",
        "ScheduleInstallDay","ScheduleInstallTime","UseWUServer"
    }
    Process {
        $PSBoundParameters.GetEnumerator() | ForEach {
            Write-Verbose ("{0}" -f $_)
        }
        ForEach ($Computer in $Computername) {
                If (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
                $WSUSEnvhash = @{}
                $WSUSConfigHash = @{}
                $ServerReg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine",$Computer)
                #Get WSUS Client Environment Options
                $WSUSEnv = $ServerReg.OpenSubKey('Software\Policies\Microsoft\Windows\WindowsUpdate')
                $subkeys = @($WSUSEnv.GetValueNames())
                $NoData = @(Compare-Object -ReferenceObject $EnvKeys -DifferenceObject $subkeys | Select -ExpandProperty InputObject)
                ForEach ($item in $NoData) {
                    $WSUSEnvhash[$item] = 'NA'
                }
                $Data = @(Compare-Object -ReferenceObject $EnvKeys -DifferenceObject $subkeys -IncludeEqual -ExcludeDifferent | Select -ExpandProperty InputObject)
                ForEach ($key in $Data) {
                    If ($key -eq 'WUServer') {
                        $WSUSEnvhash['WUServer'] = $WSUSEnv.GetValue('WUServer')
                    }
                    If ($key -eq 'WUStatusServer') {
                        $WSUSEnvhash['WUStatusServer'] = $WSUSEnv.GetValue('WUStatusServer')
                    }
                    If ($key -eq 'ElevateNonAdmins') {
                        $WSUSEnvhash['ElevateNonAdmins'] = $WSUSEnv.GetValue('ElevateNonAdmins')
                    }
                    If ($key -eq 'TargetGroupEnabled') {
                        $WSUSEnvhash['TargetGroupEnabled'] = $WSUSEnv.GetValue('TargetGroupEnabled')
                    }
                    If ($key -eq 'TargetGroup') {
                        $WSUSEnvhash['TargetGroup'] = $WSUSEnv.GetValue('TargetGroup')
                    }  
                    If ($key -eq 'DisableWindowsUpdateAccess') {
                        $WSUSEnvhash['DisableWindowsUpdateAccess'] = $WSUSEnv.GetValue('DisableWindowsUpdateAccess')
                    }              
                }
                #Get WSUS Client Configuration Options
                $WSUSConfig = $ServerReg.OpenSubKey('Software\Policies\Microsoft\Windows\WindowsUpdate\AU')
                $subkeys = @($WSUSConfig.GetValueNames())
                $NoData = @(Compare-Object -ReferenceObject $ConfigKeys -DifferenceObject $subkeys | Select -ExpandProperty InputObject)
                ForEach ($item in $NoData) {
                    $WSUSConfighash[$item] = 'NA'
                }            
                $Data = @(Compare-Object -ReferenceObject $ConfigKeys -DifferenceObject $subkeys -IncludeEqual -ExcludeDifferent | Select -ExpandProperty InputObject)
                ForEach ($key in $Data) {
                    If ($key -eq 'AUOptions') {
                        $WSUSConfighash['AUOptions'] = $WSUSConfig.GetValue('AUOptions')
                    }
                    If ($key -eq 'AutoInstallMinorUpdates') {
                        $WSUSConfighash['AutoInstallMinorUpdates'] = $WSUSConfig.GetValue('AutoInstallMinorUpdates')
                    }
                    If ($key -eq 'DetectionFrequency') {
                        $WSUSConfighash['DetectionFrequency'] = $WSUSConfig.GetValue('DetectionFrequency')
                    }
                    If ($key -eq 'DetectionFrequencyEnabled') {
                        $WSUSConfighash['DetectionFrequencyEnabled'] = $WSUSConfig.GetValue('DetectionFrequencyEnabled')
                    }
                    If ($key -eq 'NoAutoRebootWithLoggedOnUsers') {
                        $WSUSConfighash['NoAutoRebootWithLoggedOnUsers'] = $WSUSConfig.GetValue('NoAutoRebootWithLoggedOnUsers')
                    }
                    If ($key -eq 'RebootRelaunchTimeout') {
                        $WSUSConfighash['RebootRelaunchTimeout'] = $WSUSConfig.GetValue('RebootRelaunchTimeout')
                    }
                    If ($key -eq 'RebootRelaunchTimeoutEnabled') {
                        $WSUSConfighash['RebootRelaunchTimeoutEnabled'] = $WSUSConfig.GetValue('RebootRelaunchTimeoutEnabled')
                    }
                    If ($key -eq 'RebootWarningTimeout') {
                        $WSUSConfighash['RebootWarningTimeout'] = $WSUSConfig.GetValue('RebootWarningTimeout')
                    }
                    If ($key -eq 'RebootWarningTimeoutEnabled') {
                        $WSUSConfighash['RebootWarningTimeoutEnabled'] = $WSUSConfig.GetValue('RebootWarningTimeoutEnabled')
                    }
                    If ($key -eq 'RescheduleWaitTime') {
                        $WSUSConfighash['RescheduleWaitTime'] = $WSUSConfig.GetValue('RescheduleWaitTime')
                    }                                                                                                            
                    If ($key -eq 'RescheduleWaitTimeEnabled') {
                        $WSUSConfighash['RescheduleWaitTimeEnabled'] = $WSUSConfig.GetValue('RescheduleWaitTimeEnabled')
                    }  
                    If ($key -eq 'ScheduleInstallDay') {
                        $WSUSConfighash['ScheduleInstallDay'] = $WSUSConfig.GetValue('ScheduleInstallDay')
                    }  
                    If ($key -eq 'ScheduleInstallTime') {
                        $WSUSConfighash['ScheduleInstallTime'] = $WSUSConfig.GetValue('ScheduleInstallTime')
                    }  
                    If ($key -eq 'UseWUServer') {
                        $WSUSConfighash['UseWUServer'] = $WSUSConfig.GetValue('UseWUServer')
                    }                                          
                }
                
                #Display Output
                If ((-Not ($PSBoundParameters['ShowEnvironment'] -OR $PSBoundParameters['ShowConfiguration'])) -OR `
                ($PSBoundParameters['ShowEnvironment'] -AND $PSBoundParameters['ShowConfiguration'])) {
                    Write-Verbose "Displaying everything"
                    $WSUSHash = ($WSUSEnvHash + $WSUSConfigHash)
                    $WSUSHash['Computername'] = $Computer
                    New-Object PSObject -Property $WSUSHash
                } Else {
                    If ($PSBoundParameters['ShowEnvironment']) {
                        Write-Verbose "Displaying environment settings"
                        $WSUSEnvHash['Computername'] = $Computer
                        New-Object PSObject -Property $WSUSEnvhash
                    }
                    If ($PSBoundParameters['ShowConfiguration']) {
                        Write-Verbose "Displaying Configuration settings"
                        $WSUSConfigHash['Computername'] = $Computer
                        New-Object PSObject -Property $WSUSConfigHash
                    }
                }
            } Else {
                Write-Warning ("{0}: Unable to connect!" -f $Computer)
            }
        }
    }
}