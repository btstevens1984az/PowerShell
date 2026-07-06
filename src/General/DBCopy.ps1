Function Copy-SQLBackUpFile
{
<#
.Synopsis
   Copys SQL Backup Files
.DESCRIPTION
   Copy the latest SQL backup File and optionally remove the date from filename.
.PARAMETER DBName
    Name of Datebase
.PARAMETER RemoveDate
    If specified will remove the date from the file name on the copy of the backup file.
.EXAMPLE
   Copy-SQLBackUpFile  -destinationPath C:\temp\dbbackups2 -SourcePath C:\temp\dbbackups  -DBName db3  -Verbose 
.EXAMPLE
   Copy-SQLBackUpFile -DBName db3 -Verbose 
#>
    [cmdletbinding(SupportsShouldProcess=$true)]
    param([string]$SourcePath = "C:\temp\dbbackups",
          [string]$destinationPath= "C:\temp\dbbackups2",
          [string]$DBName = "DB1",
          [switch]$RemoveDate)
    #latest Backup File
    $LastBackup = Get-ChildItem -Path $SourcePath -Filter "$DBName*" |
    Sort-Object -Property lastWriteTime -Descending | 
    Select-Object -First 1
    if($RemoveDate)
    {
        $newFileName = "$DBName.bak"
        if ($pscmdlet.ShouldProcess("$($LastBackup.fullname)", "Copying Backup File to $destinationPath\$newFileName ")){
        $LastBackup | 
        Copy-Item -Destination "$destinationPath\$newFileName" -PassThru -Verbose:([bool]($PSBoundParameters.verbose.ispresent))
        }
    }
    else
    { 
        if ($pscmdlet.ShouldProcess("$($LastBackup.fullname)", "Copying Backup File to $destinationPath\$($LastBackup.name) "))
        {
        $LastBackup | 
        Copy-Item -Destination $destinationPath -PassThru -Verbose:([bool]($PSBoundParameters.verbose.ispresent))
        }
    }
   
}
#Copy-SQLBackUpFile -DBName db1  -Verbose 