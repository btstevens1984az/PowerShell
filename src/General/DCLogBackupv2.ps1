# Purpose: DCLogBackupv2 — General-purpose PowerShell utilities.

#$Filename = "C:\temp\DClogbackup\servers.csv",
Function Archive-DCLogs
{
[cmdletbinding()]
param(
$serverNames = ((Get-ADDomainController -filter *).name),
$TemparchiveDirectory = "C:\temp\archive",
$DestArchiveDirectory = "C:\temp\archive2"
)
    $ServerResults = @()
    $ServerResults =   foreach ($server in $serverNames)
    {
        $archivefiles = $null
        $ServerResult = [pscustomobject] @{
            ServerName = $server
            FileName = $null
            ArchiveStatus = $null
            ArchiveSizeMB = $null
            ArchiveExitCode = $null
            FilesInArchive = $null
            NumberFilesinArchive = $null
            ErrorDetails = $null
        }
        if (Test-Connection -Count 2 -Quiet -ComputerName $server)
        {
        Write-verbose "Moving ArchivLogs $server"
        $tempSeverArchiveDirectory = "$TemparchiveDirectory\$server"
        $ArchiveFiles = $null
        if ( -not (test-path "$TemparchiveDirectory\$server"))
        {
            Write-Verbose "Making directory: $tempSeverArchiveDirectory"
            mkdir $tempSeverArchiveDirectory -Verbose | out-null
        }   
        $TargetFolder = "\\" + $server + "\C$\Windows\System32\winevt\Logs\Archive*.evtx"
        $archiveFiles = Get-ChildItem $TargetFolder
        if($archivefiles -eq $null)
        {
            $ServerResult.archivestatus = "No Files Found"
            "no archive files found"
            $ServerResult
            continue #continue to the next server

        }
        #move to temp archive location
        $ArchiveFiles | Move-Item -Destination $tempSeverArchiveDirectory -Verbose -ErrorVariable FileCopyErrs
        If ($FileCopyErrs)
        {
            $ServerResult.archivestatus = "Failed"
            $serverResult.ErrorDetails = "Failed file copy from $server"
            $ServerResult
            continue
            #Log move unsuccessful
        }
        $now = get-date -Format "MMddyyyyss"
        $zipFile ="$TemparchiveDirectory\"+$server+"_$now.7z"
        #Create Archive, Currently we don't do anything with $7zipoutput
        $7zipoutput= & "C:\Program Files\7-Zip\7z.exe" a -t7z $ZipFile $tempSeverArchiveDirectory
        if ($LASTEXITCODE -eq 0)
        {
            #zip success
            $ArchiveFile = Get-item $zipFile
            Remove-Item -Path $tempSeverArchiveDirectory -Verbose -Recurse -Force
            #$ServerResult.ArchiveStatus = "Success"
            $ServerResult.ArchiveExitCode = $LASTEXITCODE
            $ServerResult.ArchiveSizeMB = [int]($ArchiveFile.Length / 1MB)
            $ServerResult.FileName = $ArchiveFile.Name
            $ServerResult.FilesInArchive = $ArchiveFiles.Name -join ";"
            $ServerResult.NumberFilesinArchive = $ArchiveFiles.count
        }
        else
        {
            #zip failure
            $ServerResult.ArchiveStatus = "Failed"
            $ServerResult.ArchiveExitCode = $LASTEXITCODE
            $LASTEXITCODE = $null
            $ServerResult
            continue
        }
        
        if ( -not (test-path "$DestArchiveDirectory\$server"))
        {
            mkdir "$DestArchiveDirectory\$server" -Force -Verbose
        }
       #Archiving
       Move-Item $ZipFile "$DestArchiveDirectory\$server" -Force -Verbose -ErrorVariable MoveErrs
       if ($MoveErrs)
       {
            $ServerResult.ArchiveStatus = "Failed"
            $serverResult.ErrorDetails = "File move to archive serve failed"
       }
       else
       {#everything worked
            $ServerResult.ArchiveStatus = "Success"
       }

    } #end if
    else
    {
        $ServerResult.ArchiveStatus = "Failed"
        $ServerResult.ErrorDetails = "Ping failed"
        
    }
    $ServerResult
    }
    $ServerResults    
}
$tempDirectory = "c:\temp\Archive"
$results = Archive-DCLogs -Verbose -TemparchiveDirectory $tempDirectory 

$attachments =@()
$results | Export-Clixml "$tempDirectory\results.xml"
$attachments +="$tempDirectory\results.xml"
if ($error) 
{
    $Error | Export-Clixml "$tempDirectory\errors.xml"
    $attachments +="$tempDirectory\errors.xml"
}

#$cred = Get-credential
$params = @{
                SMTPServer = "smtp.office365.com"
                port = 587
                from = "Jeff@dykstras.net"
                to = "Jeff.Dykstra@microsoft.com"
                credential = $cred
                subject = "DC Event Log Archive Report"
                BodyAsHtml = $true
                Body = $results| ConvertTo-Html -CssUri C:\temp\example.css | Out-String
                UseSSL = $true
                verbose = $true
                Attachments = $attachments

            }
 Send-MailMessage @params
