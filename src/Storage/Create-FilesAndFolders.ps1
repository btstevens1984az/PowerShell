# Purpose: Create-FilesAndFolders — Storage management and disk operations.
Join-Path -Path $HOME -ChildPath Documents -OutVariable myDocuments

New-Item -Path $myDocuments\Finance -ItemType Directory
New-Item -Path $myDocuments\Finance\Public -ItemType Directory
New-Item -Path $myDocuments\Finance\Private -ItemType Directory

1..10 | 
Foreach-Object {
New-Item –Path $myDocuments\Finance\Public –Name Public-$_.txt –ItemType file
New-Item –Path $myDocuments\Finance\Public –Name Public-$_.log –ItemType file
New-Item –Path $myDocuments\Finance\Private –Name Private-$_.txt –ItemType file
New-Item –Path $myDocuments\Finance\Private –Name Private-$_.log –ItemType file
}