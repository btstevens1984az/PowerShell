# Purpose: Parse-WindowsUpdateLog — Standalone GUI applications and utilities.
Function Parse-WindowsUpdateLog {
    <#
    .Synopsis
    Parse WindowsUpdate.Log file on local/remote computers
    .Description
    Retrieve Windows Update information from the 'WindowsUpdate.Log' file from local/remote Windows server,
    parse and create outputs as PSCustom objects
    .Link
    http://powershelldistrict.com/windowsupdate-log/   (inspired by Stephane van Gulick's blog on the regex match pattern part)
    
    .Parameter ComputerName
    A single remote ComputerName passes to the function

    .Parameter Date
    Pass a specific date to the function which only queries Windows Updates on that date.

    .Parameter BeforeDate
    Pass a specific date to the function which only queryes Windows Updates installed before that date.

    .Parameter AfterDate
    Pass a specific date to the function which only queryes Windows Updates installed After that date.

    .Parameter KB
    function quires on specific KBs 
  
    .Example
    PS C:\> Parse-WindowsUpdateLog -computername 235.34.69.151
    Command retrieves the WindowsUpdate.Log file from computer ServerA, then output all available 
    updates information from the log file

    
    .Example
    PS C:\> Parse-WindowsUpdateLog -computername 235.34.69.151 -KB KB890830,KB4033428
    Queries KB890830 and KB4033428 on a remote computer - SERVERA

    .Example
    PS C:\> Parse-WindowsUpdateLog -computername 189.9.63.199 -Beforedate 09/17/2017
    Queries updates which were installed before 09/17/2017 on a remote computer - SERVERB

    .Example
    PS C:\> Parse-WindowsUpdateLog -computername 189.9.63.199 -Afterdate 09/17/2017
    Queries updates which were installed after 09/17/2017 on a remote computer - SERVERB

     .Example
    PS C:\> Parse-WindowsUpdateLog -computername 189.9.63.199 -date 09/17/2017
    Queries updates which were installed on 09/17/2017 on a remote computer - SERVERB

    
    #>  
    [CmdletBinding(DefaultParameterSetName='Default')]
    Param (
        [Parameter(Mandatory=$false,ValueFromPipeline)]
        [string]$ComputerName = $env:COMPUTERNAME,

        [Parameter(Mandatory=$false)][datetime]$Date,

        [Parameter(Mandatory=$false,ParameterSetName='ByKB')]
        [string[]]$KB,

        [Parameter(Mandatory=$false,ParameterSetName='ByAfterDate')]
        [datetime]$AfterDate,

        [Parameter(Mandatory=$false,ParameterSetName='ByBeforeDate')]
        [datetime]$BeforeDate
    )
    
    Process {
        write-host "`n********************Querying Computer - [$ComputerName] ********************`n " -ForegroundColor Cyan
        
        try {
            $WindowsLogFilePath = "\\$ComputerName\C`$\Windows\WindowsUpdate.log"
            Test-Path $WindowsLogFilePath -ErrorAction 'Stop' | out-null
            $RawContent = Get-Content -path $WindowsLogFilePath -Encoding UTF8 -ReadCount 0
    
        }Catch{
            Write-Warning "$_.Exception.Message"
        }

        #as described here https://support.microsoft.com/en-us/kb/902093
        $Pattern = '(?<Date>\d{4}-\d{2}-\d{2})\t(?<Time>\d{2}:\d{2}:\d{2}:\d{3})\s+(?<PID>\d{3,4})\s(?<TID>\w{3,4})\s(?<Component>\w{0,})\s(?<Message>.*$)'
        $objects = New-Object System.Collections.ArrayList
        $objects = foreach ($line in $RawContent){
            if ($line -match $Pattern){
                $hash = [Ordered]@{}
                $hash.Date = $Matches.Date
                $hash.Time = $Matches.Time
                $hash.PID = $Matches.PID
                $hash.TID = $Matches.TID
                $hash.Component = $Matches.Component
                $hash.Message = $Matches.Message
                [pscustomobject]$hash
            }
        }

        $UpdatesInLog = @() #All update records which are in the update log file 
        $Pattern = 'Title\s=\s(?<UpdateName>.{1,})'
        $UpdatesInLog= foreach ($o in $objects){
            If ($o.Message -match $Pattern){
                $h = [Ordered]@{}
                $h.Date = $o.date
                $h.time = $o.time
                $h.UpdateName = $Matches.UpdateName
                [pscustomobject]$h
            }
        }

        if ($UpdatesInLog) {
            #put all unique KBs into an array variable - $UpdatesInLog
            $UniqueUpdateNames = $UpdatesInLog.UpdateName | select -Unique

            #use regex look ahead to insert a '\' ahead of '(' and ')'
            $UniqueUpdateNamesRX = $UniqueUpdateNames | foreach {$_ -replace '(?=\(|\))','\'}

            #below filteredobject should have all KB included, but also could be duplicated
            $FilteredObjects = $objects | where {$_.Message -match 'KB\d{6,7}' -and $_.Component -eq 'Report'}
            #Add a property [UpdateName] to each object
            $FilteredObjects | ForEach-Object {
                Add-Member -InputObject $_ -MemberType NoteProperty -name KB -Value ($_.Message -replace '.*(KB\d{6,7}).*','$1')
                Add-Member -InputObject $_ -MemberType NoteProperty -name UpdateName -Value ($_.Message -split ":")[-1].trim()
            }

            #filtered log entries which only contains conents about KBxxxxxxx and component type is 'Report' only
            $FilteredLogs = New-Object System.Collections.ArrayList
            $FilteredLogs = foreach ($update in $UniqueUpdateNamesRX) {
                $FilteredObjects | where {$_.Message -match $update -and $_.Component -eq 'Report'}
            }

            $FilteredHash = $FilteredLogs | group KB -AsHashTable
    
            $FinalResult = Foreach ($name in $FilteredHash.keys) {
                $objs = $Filteredhash.$name | sort Date,Time -Descending
                foreach ($obj in $objs) {
                    if ($obj.Message -match 'Installation Successful') {
                        $ResultHash = [ordered]@{
                            UpdateName = $obj.UpdateName
                            KB = $obj.KB
                            InstallStatus = 'Successful'
                            Date = $obj.Date
                            Time = $obj.Time
                            Message = ($obj.Message -split ":")[-2].trim() + " -$($obj.KB)"
                        }
                        break
                    }
                    elseif ($obj.Message -match 'Installation Failure') {
                        $ResultHash = [ordered]@{
                            UpdateName = $obj.UpdateName
                            KB = $obj.KB
                            InstallStatus = 'Failed'
                            Date = $obj.Date
                            Time = $obj.Time
                            Message = ($obj.Message -split ":")[-2].trim() + " -$($obj.KB)"
                        }
                        break
                    } else {
                        $ResultHash = [ordered]@{
                            UpdateName = $obj.UpdateName
                            KB = $obj.KB
                            InstallStatus = 'Not Installed'
                            Date = $obj.Date
                            Time = $obj.Time
                            Message = ($obj.Message -split ":")[-2].trim() + " -$($obj.KB)"
                        }            
                    } 
                }
                [pscustomobject]$ResultHash
            }

            if ($date) {
                $filteredDate = get-date $date -UFormat %Y-%m-%d
                Write-Verbose "Returning sorted objects on date $($date)"
                $DateResult = $FinalResult | where {$_.Date -eq $filteredDate} | sort Time -Descending
                if (-not $DateResult) {
                    Write-Warning "No updates are found in WindowsUpdate.Log file on date $filteredDate"
                    return
                }else{
                    $DateResult
                    write-host "*******************************************************************************" -ForegroundColor Cyan
                    return
                }
            }elseif ($AfterDate) {
                $filteredDate = get-date $AfterDate -UFormat %Y-%m-%d
                Write-Verbose "Returning sorted objects after date $($date)"
                $AfterResult = $FinalResult | Where {[datetime]($_.Date) -gt [datetime]$filteredDate} | sort Date, Time -Descending
                if (-not $AfterResult) {
                    Write-Warning "No updates are found in WindowsUpdate.Log file after date $filteredDate"
                    return
                }else{
                    $AfterResult 
                    write-host "*******************************************************************************" -ForegroundColor Cyan
                    return
                }
            }elseif ($BeforeDate) {
                $filteredDate = get-date $BeforeDate -UFormat %Y-%m-%d
                Write-Verbose "Returning sorted objects before date $($date)"
                $BeforeResult = $FinalResult | Where {[datetime]($_.Date) -lt [datetime]$filteredDate} | sort Date, Time -Descending
                if (-not $BeforeResult) {
                    Write-Warning "No updates are found in WindowsUpdate.log file before date $filteredDate"
                    return
                }else{
                    $BeforeResult
                    write-host "*******************************************************************************" -ForegroundColor Cyan
                    return
                }
            }

            if ($KB) {
                Write-Verbose "Returning sorted objects which KB number is/are $KB"
                $KBResult = foreach ($KBnumber in $KB) {
                    $KBR = $FinalResult | Where {$_.KB -eq $KBnumber}
                    if (-not $KBR) {
                        Write-Warning "Update - $KBnumber is not found in the WindowsUpdate.Log file"
                    }else{
                        $KBR
                    }
                }
                $KBResult
                write-host "*******************************************************************************" -ForegroundColor Cyan
                return
            }

            $FinalResult | sort Date,Time -Descending
            write-host "*******************************************************************************" -ForegroundColor Cyan

        }else{
            write-warning "No updates are found in the WindowsUpdate.Log file on computer [$ComputerName]"
            write-host "*******************************************************************************" -ForegroundColor Cyan
        }#if/else

    }#process

}