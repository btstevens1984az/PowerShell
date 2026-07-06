
Function Remove-PRFAppFiles
{
<#
.Synopsis
   Removes PRF app files and corresponding file.
.DESCRIPTION
    Removes PRF app files and corresponding file with the same basename but different extention.
.PARAMETER  Directory
    Specify the top level directory the contains the folders with PRF files.
.PARAMETER RententionDays
    Files older than the number of retention days will be deleted.
.PARAMETER Folders
    If specified, empty folders 2 levels down from the Directory parameter will be deleted.
.EXAMPLE
   See what files and folders would be removed without removing them.
    Remove-PRFAppFiles  -WhatIf -folders
.EXAMPLE
   Remove files and folders with verbose output and progress bar.
    Remove-PRFAppFiles -directory C:\NRPortbl -Verbose -folders -progress
.EXAMPLE
   Remove files and folders with verbose output and progress bar and export log to xml
    Remove-PRFAppFiles -directory C:\NRPortbl -Verbose -folders -progress | export-clixml .\PRFLog1.xml
.EXAMPLE
   Remove files and folders with verbose output and progress bar and display results
    $output = Remove-PRFAppFiles -directory C:\NRPortbl -Verbose -folders -progress
    $output.EmptyFoldersDeleted  |Select-Object -Property Fullname,LastWriteTime,WhenDeleted |  Out-GridView
    $output.FilesDeleted | Select-Object -Property Fullname,LastWriteTime,WhenDeleted |  Out-GridView
.OUTPUTS
   PSCustomObject
#>
    
    [cmdletbinding(SupportsShouldProcess=$true)]
    [OutputType([PSCustomObject])]
    param(
        [string]$Directory = 'C:\NRPortbl\',
        [switch]$Folders,
        [ValidateRange(7,1000)]
        [int]$RetentionDays=30,
        [switch]$progress
    )
    $filesRemoved = @()
    $foldersRemoved = @()
    $cutoff = (Get-Date).AddDays(-$RetentionDays)
    $DateTime = $(get-date -f yyyy-MM-dd_hh.mm.ss)
    $ComputerName = $(gc env:computername)
    $Logfile = "C:\NRPortbl\" + $ComputerName + "_" + $DateTime + ".log"
    #$Dirlist = Get-ChildItem -Recurse 
    #$OlDPRFs = $Dirlist | Where-Object {$_.Extension -eq '.prf'}
    $OlDPRFs = Get-ChildItem -Path $directory -Recurse -Include *.prf | Where-Object {$_.lastwritetime -lt $cutoff}
    $PRFProgressCount= 1
    Foreach ($prf in $OlDPRFs)
    {

        if($progress)
        {
        Write-Progress -Activity "Processing PRFs" -CurrentOperation "Checking $($prf.fullname)" -PercentComplete ($PRFProgressCount/$OlDPRFs.count *100)
        $PRFProgressCount++
        }
        $OtherFile = dir "$($prf.PSparentpath)\$($prf.BaseName).*" -Exclude *.prf

        if ( $OtherFile.LastWriteTime -lt $cutoff)
        {
           $target = "$($prf.Fullname);$($OtherFile.Fullname)"
           if ($pscmdlet.ShouldProcess($target, "Removing files"))
           { 
            $prf,$OtherFile | Remove-Item 
            LogWrite -logstring "Deleted $target" -FileName $Logfile
            $prf,$OtherFile | Add-Member -MemberType NoteProperty -Name WhenDeleted -Value (Get-date)
            $filesRemoved += $prf,$OtherFile
           }
        }

    }
    if ($folders)
    {
        $subfolders = Get-ChildItem -Path $directory | Where-Object {$_.PSIsContainer} | Get-ChildItem | Where-Object {$_.PSIsContainer} 
        $subFolderProgressCount = 1
        foreach($folder in $subfolders)
        {
            if(-not(Get-childitem -Recurse -Path $folder.fullname | where-object {$_.PSIscontainer -eq $false}))
            {
                if($progress)
                {
                Write-Progress -Activity "Processing SubFolders" -CurrentOperation "Checking $($folder.fullname)" -PercentComplete ($subFolderProgressCount/$subfolders.count *100)
                $subFolderProgressCount++
                }
                if($pscmdlet.ShouldProcess(($folder.fullname), "Deleting empty folder"))
                {
                    $folder | Remove-Item
                    LogWrite -logstring "Deleted empty folder $target" -FileName $Logfile
                    $folder | Add-Member -MemberType NoteProperty -Name WhenDeleted -Value (Get-date)
                    $foldersRemoved += $folder
                }
            }
        }
    }

    [pscustomobject]@{
                        FolderProcessed = $Directory
                        EmptyFoldersDeleted = $foldersRemoved
                        FilesDeleted = $filesRemoved

                    }
} 

Function LogWrite
{
   Param ([string]$logstring,
   $FileName ="C:\NRPortbl\$($env:computername)_$(get-date -f yyyy-MM-dd_hh.mm.ss).log")
   Add-content $FileName -value $logstring
}

#Remove-PRFAppFiles  -WhatIf -folders -progress
#Remove-PRFAppFiles -directory C:\NRPortbl -Verbose -folders -progress
#Remove-PRFAppFiles -Verbose -folders

#$output = Remove-PRFAppFiles -directory C:\NRPortbl -Verbose -folders -progress
#$output.EmptyFoldersDeleted  |Select-Object -Property Fullname,LastWriteTime,WhenDeleted |  Out-GridView
#$output.FilesDeleted | Select-Object -Property Fullname,LastWriteTime,WhenDeleted |  Out-GridView