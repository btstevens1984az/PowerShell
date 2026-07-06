# Purpose: Events-JEFFDYK1 — General-purpose PowerShell utilities.
# PowerShell Eventing
# 3 types of events PowerShell can subscribe to: .NET, WMI, Powershell Engine
# .NET Event subscriptions
if (!(test-path "c:\testevents")) { new-item -path c:\ -name testevents -type directory >$null}
if (!(test-path "c:\testevents2")) { new-item -path c:\ -name testevents2 -type directory >$null}
# create a system.io.filesystemwatcher object 
$folderwatcher = new-object system.io.filesystemwatcher("C:\testevents")
# list the objects event members
$folderwatcher | get-member -membertype event
# 6 events we can subscribe to : Changed, Created, Deleted, Disposed, Error, Renamed
# register a subscription to the created event using Register-ObjectEvent cmdlet
Register-ObjectEvent $folderwatcher created -sourceidentifier filesystemwatcher.created 
$EventJob = Register-ObjectEvent $folderwatcher created -sourceidentifier filesystemwatcher.created.action -Action {
$FullPath =$event.SourceArgs[1].fullpath
  $parentPath = $fullpath  | Split-Path -Parent 
  $start = Get-Date
  Function CopyNewFile
  {
     $now = Get-Date
     if ($now -gt ($start.AddSeconds(30)))
     {
        break
     }
     try {Copy-Item $FullPath "C:\testevents2\$($event.SourceArgs[1].name)"  -ErrorAction stop}
     catch [System.IO.IOException]
     {
        Start-Sleep -Milliseconds 100
        copynewfile
     }  
  }
  CopyNewFile
  }
New-Item -Path C:\testevents -Name testfile232.txt -ItemType file
# list all events
Get-Event
# register a subscription to the changed event
Register-ObjectEvent $folderwatcher changed -sourceidentifier filesystemwatcher.changed
Add-Content -Value "123456789" -Path C:\testevents\testfile.txt
# list all events
Get-Event
# register a subscription to the deleted event
Register-ObjectEvent $folderwatcher deleted -sourceidentifier filesystemwatcher.deleted
Remove-Item -Path C:\testevents\testfile.txt -Force
# list all events
Get-Event
# list the event subscriptions
Get-EventSubscriber
# remove all event subscriptions
Unregister-Event -SourceIdentifier *

#get-event | remove-event