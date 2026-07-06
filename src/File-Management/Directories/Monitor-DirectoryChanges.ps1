# Purpose: Monitor-DirectoryChanges — File and folder management utilities.
Function Monitor-DirectoryChanges {
#Monitoring Folder Content
#use a FileSystemWatcher object to monitor a folder and send an email when a file is added or deleted.
# make sure this folder exists. Script will monitor changes to this folder:
Write-Host "Begin Monitoring"
$folder = "C:\Temp"
$timeout = 1000
$FileSystemWatcher = New-Object System.IO.FileSystemWatcher $folder
Write-Host "Press CTRL+C to abort monitoring $folder"
while ($true) {$result = $FileSystemWatcher.WaitForChanged("all", $timeout)
    if ($result.TimedOut -eq $false)
        {
            Write-Warning ("File {0} : {1}" -f $result.ChangeType, $result.name)
            #send an email when it happens
                #for Outlook email use below
                #open Outlook > File > Account Settings > Select work email account > Change > copy server name and work email > DO NOT EDIT!!
                #use that data to change below
            $PSEmailServer = 'smtp.gmail.com'
            Send-MailMessage -To "btstevens1984az@gmail.com" -From "btstevens1984az@gmail.com" -Subject "Temp Folder Changed" -SmtpServer $PSEmailServer
        }
}
Write-Host "Monitoring aborted."
}