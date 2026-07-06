# Purpose: Disk Cleanup — Storage management and disk operations.
## Sometimes there's weird certificate settings so this is just a quick set to make sure our
## download will go through
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
## Sometimes downloading via Powershell fails due to TLS settings on the local machine so this
## is just making sure TLS settings will allow our download
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Ssl3

## Gets total disk space available before cleaning starts
$sysDrive = $env:SystemDrive
$diskBefore = (Get-WmiObject Win32_LogicalDisk).FreeSpace | Measure-Object -Sum

## Set paths as vars
$OS = Get-WMiobject -Class Win32_operatingsystem
$ccleanerUrl = "https://support.dkbinnovative.com/labtech/transfer/software/piriform/ccleaner.exe"
$ccleanerConfigUrl = "https://support.dkbinnovative.com/labtech/transfer/software/piriform/ccleaner.ini"
$ccleanerDir = "$sysDrive\Windows\LTSvc\packages\Software\CCleaner"
$ccleanerExe = "$ccleanerDir\CCleaner.exe"
$ccleanerIni = "$ccleanerDir\ccleaner.ini"
$logFile = "$sysDrive\Windows\LTSvc\diskCleanup.txt"

If (!(Test-Path $ccleanerDir)) {
    New-Item -Path $ccleanerDir -ItemType Directory | Out-Null
}

Try {
    If ((Test-Path $ccleanerExe -PathType Leaf)) {
        Write-Output 'Ccleaner.exe exists, checking file size...'
        ## For some reason when downloading from google drive once and awhile it just won't finish the download
        ## so a byte check really is necessary to make sure CCleaner downloads succesfully. Long play is to move
        ## this to an FTP server, just haven't had a chance.
        If ((Get-Item $ccleanerExe -ErrorAction SilentlyContinue).Length -ne '13594584') {
            Write-Warning 'Ccleaner does exist, but the file size does not match the server. Re-downloading...'
            (New-Object System.Net.WebClient).DownloadFile($ccleanerUrl, $ccleanerExe)
        } Else {
            Write-Output 'Verified Ccleaner.exe file size is correct, executing Ccleaner...'
        }
    } Else {
        Write-Warning 'Ccleaner.exe does not exist, downloading file...'
        (New-Object System.Net.WebClient).DownloadFile($ccleanerUrl, $ccleanerExe)
    }

    If(!(Test-Path $ccleanerIni -PathType Leaf)) {
        (New-Object System.Net.WebClient).DownloadFile($ccleanerConfigUrl, $ccleanerIni)
    }
} Catch {
    Write-Error "!ERROR: Failed to download required files, exiting script"
}


## Starts the CCleaner process
Try {
    Start-Process -FilePath $ccleanerExe -ArgumentList "/AUTO" -Wait
    Write-Output 'CCleaner complete!'
} Catch {
    Write-Warning '!ERROR: There was a problem running Ccleaner.exe, unable to complete this task'
}

## Deletes old windows update files and old versions of Windows
## Using CMD RD instead of Remove-Item since in the past have had several issues with Remove-Item hanging on
## permission issues instead of skipping and moving on. This is even with trying -Confirm:$False -Force etc.
$folders = "$sysDrive\Windows10Upgrade","$sysDrive\Windows\SoftwareDistribution\Download"#,"$sysDrive\Windows.old"
ForEach($folder in $folders){
    If((Test-Path $folder)){
        &cmd.exe /c echo y| takeown /F $folder\* /R /A /D Y 2>&1 | Out-Null
        &cmd.exe /c echo y| cacls $folder\*.* /T /grant administrators:F 2>&1 | Out-Null
        &cmd.exe /c RD /S /Q $folder 2>&1 | Out-Null
        Write-Output "Deleted $folder"
    }
}
Write-Output "Windows temp system file cleanup complete!"


## Deletes temp files
## Using CMD RD instead of Remove-Item for same reasons as above
$tempCount = 0
If (!$excludeCTemp) {
    $folders = "$env:TEMP","$env:SystemDrive\Temp","$env:windir\Temp"
} Else {
    $folders = "$env:TEMP","$env:windir\Temp"
}


$ErrorActionBefore = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'
<#
## Old temp file manual cleanup, deleting entire folder and causing issues
ForEach ($folder in $folders) {
    Get-ChildItem $folder -Recurse | ForEach-Object {
        $tempCount++
        $item = $_.FullName
        Try {
            ## We've had issues with IIS if you mess with the inetpub temp so we are excluding that in this IF statement
            If ($item -notlike '*inetpub*') {
                #Remove-Item $item -Recurse -Force -ErrorAction Stop
                Get-ChildItem -Path $item -Exclude '*.txt' -Include '*' -File -Recurse | Where-Object { $_.Directory.Name -ne '*inetpub*' } | Remove-Item -Force -Confirm:$False
                #Write-Output "Deleted $item"
            }
        } Catch {
            $tempCount--
            #Write-Warning "Failed to delete $item"
        }
    }
}
#>

## NEW removal method, does not delete folders.
## If this is a server we're going to skip this section. After quite awhile in prod, we've found it's common for LoB
## applications to store vital data in C:\Windows\Temp, and C:\Temp...weird, but definitely exists and clearing them
## breaks applications. This is also excluding inetpub (IIS), WindowsUpdateLog folder, and .log files.
$os = (Get-WmiObject win32_operatingsystem).Caption
If ($os -notlike '*Server*') {
    ForEach ($folder in $folders) {
        "Removing files from $folder..."
        Get-ChildItem -Path $folder -Exclude '*.log' -Include '*' -File -Recurse | Where-Object { $_.Directory.Name -notlike '*inetpub*' -and $_.Directory.Name -notlike '*WindowsUpdateLog*' } | Remove-Item -Force -Confirm:$False
    }
}
$ErrorActionPreference = $ErrorActionBefore


If ($tempCount -eq 0) {
    $folders = $folders.Split(' ')
    Write-Output "No temp items were found that can be removed at this time from $folders"
} Else {
    Write-Output "Successfully removed $tempCount temp items, general temp file removal complete!"
}


## Verifies disk cleanup is present, runs it if true
If ((Test-Path "$env:windir\System32\cleanmgr.exe" -PathType Leaf)) {
    $diskCleanRegPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\'
    ## Every item in this long list below is an item on DiskCleanup that will be checked and cleaned through this script
    $cleanItems = 'Active Setup Temp Folders','BranchCache','Content Indexer Cleaner','D3D Shader Cache','Delivery Optimization Files','Device Driver Packages','Diagnostic Data Viewer database files','Downloaded Program Files','Internet Cache Files','Language Pack','Offline Pages Files','Old ChkDsk Files','Previous Installations','Recycle Bin','RetailDemo Offline Content','Service Pack Cleanup','Setup Log Files','System error memory dump files','System error minidump files','System error minidump files','Temporary Setup Files','Thumbnail Cache','Update Cleanup','User file versions','Windows Defender','Windows Error Reporting Files','Windows ESD installation files','Windows Upgrade Log Files'

    ForEach ($item in $cleanItems) {
        $curProperty = Get-ItemProperty -Path "$diskCleanRegPath\$item" -Name StateFlags0778 -ErrorAction SilentlyContinue
        If (!$curProperty -or $curProperty.StateFlags0778 -ne 2) {
            Write-Output "Setting $item to enabled in Disk Cleanup"
            New-ItemProperty -Path "$diskCleanRegPath\$item" -Name StateFlags0778 -Value 2 -PropertyType DWORD -ErrorAction SilentlyContinue | Out-Null
        }
    }
    &cmd.exe /c echo y| cleanmgr /sagerun:0778
    ## Check to see if cleanmgr is still running since this often gets hung up and stops the script. This is
    ## pretty extensive just to check if cleanmgr is running, but the alternative is letting this get hung up
    ## and the script in Automate just gets stuck untilt he couple hour timeout hits.
    $proc = 'cleanmgr'
    If (Get-Process $proc -ErrorAction SilentlyContinue) {
        ## Define the number of minutes the countdown timer should allow it to gracefully finish before giving up and killing cleanmgr.
        $CountDownTimer = 10
        Write-Host " "
        Write-Warning "$proc is still running. Waiting up to $CountDownTimer minutes for it to gracefully complete so the script can proceed."
        $diskCleanupRunning = $True
        $StartTime = Get-Date
        $EndTime = $StartTime.AddMinutes($CountDownTimer)
        $TimeSpan = New-TimeSpan (Get-Date) $EndTime
    }
    ## While the process is still running, or there is time remaining in the timespan countdown, loop through writing a progress bar and check to see if the process is still running.
    While ($diskCleanupRunning -and ($TimeSpan.TotalSeconds -gt 0)) {
        Write-Progress -Activity "Waiting for $proc to complete." -Status "$CountDownTimer minute countdown before the script kills $proc." `
            -SecondsRemaining $TimeSpan.TotalSeconds
        Start-Sleep -Seconds 1
        ## Recheck to see if the process is still running. It will return a $Null/$False value if it isn't for evaluation at the beginning of the loop.
        $diskCleanupRunning = Get-Process $proc -ErrorAction SilentlyContinue
        ## Recalculate the new timespan at the end of the loop for evaluation at the beginning of the loop.
        $TimeSpan = New-TimeSpan (Get-Date) $EndTime
    }
    ## Close out the progress bar cleanly if it was still running.
    Write-Progress -Activity "Waiting for $proc to complete." -Completed -Status 'Complete'
    ## If cleanmgr is still running after the end count time timer, kill cleanmgr. Otherwise note the time it took cleanmgr to complete.
    If ($diskCleanupRunning) {
        Write-Host "$proc is still running after the $CountDownTimer time expired, and will hang up the rest of this disk cleanup script."
        Stop-Process -Name cleanmgr -Force
    } ElseIf ($CountDownTimer) {
        ## Calculate the completed time by taking the timespan of the start time versus the end time, where the end time has the seconds the loop took to run subtracted from it.
        $CompletedTime = (New-TimeSpan $StartTime $Endtime.AddSeconds(-$TimeSpan.TotalSeconds)).ToString("mm':'ss")
        Write-Host "$proc has finished after $CompletedTime."
        Write-Host " "
    }
    Write-Host "$proc (built in windows disk cleanup) complete!"
}


<#
WinSxs Cleanup
The /Cleanup-Image parameter of Dism.exe provides advanced users more options to further
reduce the size of the WinSxS folder. To reduce the amount of space used by a Service
Pack, use the /SPSuperseded parameter of Dism.exe on a running version of Windows to
remove any backup components needed for uninstallation of the service pack.
#>
$dismSP = &cmd.exe /c "dism.exe /Online /Cleanup-Image /SPSuperseded"
If ($dismSP -like '*Service Pack Cleanup cannot proceed: No Service Pack backup files were found.*') {
    Write-Warning 'No service packs to remove with DISM'
} Else {
    Write-Output 'DISM service pack cleanup complete'
}

<#
Service Pack Cleanup
Using the /ResetBase switch with the /StartComponentCleanup parameter of DISM.exe on a
removes all superseded versions of every component in the component store
#>
$dismWinSxs = &cmd.exe /c "dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase"
If ($dismWinSxs -like '*The operation could not be completed due to pending operations.*') {
    Write-Warning 'Unable to complete DISM WinSxs cleanup due to operations pending, ususally this means pending reboot'
} Else {
    Write-Output 'DISM WinSxs cleanup complete'
}


## Empty recycle bin
Try {
    $definition = @'
[DllImport("Shell32.dll", CharSet = CharSet.Unicode)]
public static extern uint SHEmptyRecycleBin(IntPtr hwnd, string pszRootPath, uint dwFlags);
'@
    $winApi = Add-Type -MemberDefinition $definition -Name WinAPI -Namespace Extern -PassThru
    $winApi::SHEmptyRecycleBin(0, $null, 7) | Out-Null
    Write-Output 'Recycling bin successfully emptied'
} Catch {
    Write-Warning '!ERROR: There was a problem when attempting to empty the recycling bin, unable to complete this task.'
}

## Delete old items in the LTSvc folder
$ltsvcPath = "$env:windir\LTSvc\packages"
$age = 30
If ((Test-Path -Path $ltsvcPath)) {
    ## Only delete items $age old or older, and do not delete files directly in the Ninite or PSExec folders.
    ## Ninite holds logs, and PSExec we use for various tasks so we want to leave both of those.
    Get-ChildItem -Path $ltsvcPath -Exclude '*.txt' -Include '*' -File -Recurse |
    Where-Object { $_.Directory.Name -ne 'PSExec' } |
    Where-Object { $_.Directory.Name -ne 'SWP' } |
    Where-Object { $_.Directory.Name -ne 'TCRS' } |
    Where-Object { $_.Directory.Name -ne 'Icons' } |
    # Only delete items older than $age days
    Where-Object { $_.LastWriteTime -le (Get-Date).AddDays(-$age) } |
    Remove-Item -Force -Confirm:$False
}

## Gets the available space of all drives after cleaning
$diskAfter = (Get-WmiObject Win32_LogicalDisk).FreeSpace | Measure-Object -Sum

## Uses the values from the total disk space used before and after this script to calculate
## total space saved, then converts it to MBs for easier reading
$before = [math]::Round($diskBefore.Sum/1MB,2)
$after = [math]::Round($diskAfter.Sum/1MB,2)
$saved = [math]::Round(($after - $before),2)
$savedGBs = [math]::Round(($saved * 1024 * 1024 / 1GB),2)
## If there is less space than before the script started just report back 0
If($saved -le 0) {
    $saved = 0
}

## Formats the output so we can split vars in Automate
Write-Output "trashVar='None'|before=$before|after=$after|spaceSaved=$saved|spaceSavedGBs=$($savedGBs)GBs"
. 'C:\Users\btste\OneDrive\WindowsPowerShell\Scripts\Disk_Cleanup.ps1'
