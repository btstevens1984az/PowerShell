# Purpose: Archive-Files — Storage management and disk operations.
# Create a new folder on 2012R2-MS
New-Item -Path \\10.32.195.22\C$\DocumentBackup -ItemType directory –Force

# Share the folder as 'Backup'
New-SmbShare -CimSession (New-CimSession -ComputerName 10.32.195.22) `
-Path C:\DocumentBackup -Name Backup -FullAccess "Contoso\Domain Users" -ErrorAction SilentlyContinue

# Create a new variable
Join-Path -Path $HOME -ChildPath Documents -OutVariable docs

# Create a directory called 'myFolder' on the 'Backup' remote share 
New-Item –Path \\10.32.195.22\Backup -Name $env:USERNAME -ItemType directory –OutVariable myFolder -Force

# create a local 'Archive' folder within the current user's 'Documents' directory
New-Item -Path $docs\Archive -ItemType Directory -Force

# Map a new temporary network drive
New-PSDrive –Name MyBackup –root $myFolder.FullName –Psprovider filesystem -ErrorAction SilentlyContinue

# Set the LastWriteTime file property to 60 days in the past for local files
Get-ChildItem -Path $docs\Finance -Recurse | Set-ItemProperty -Name LastWriteTime -Value (Get-Date).AddDays(-60)

# Add the current username value to each .txt file to modify the LastWriteTime property
Get-ChildItem -Path $docs\Finance -Filter *.txt -Recurse | Set-Content -Path {$_.fullname} -Value $env:USERNAME

# Get all files modified more than a month ago
Get-Childitem -File -Path $docs\Finance -Recurse | 
Where LastWriteTime -lt (Get-Date).addDays(-30) |
Foreach-Object {

# Preserve folder structure
New-Item -Path $docs\Archive\Finance\$($_.Directory.Name) -ItemType container -ErrorAction SilentlyContinue

# copy the files to the 'Finance\Archive' directory
Copy-Item -Path $_.FullName -Destination $docs\Archive\Finance\$($_.Directory.Name)
}

# Rename file extensions from '.log' to '.old'
Get-ChildItem -Path $docs\Archive\Finance -File -Recurse  | 
Rename-Item -NewName { $_.fullname.replace(".log",".old") }

# Use BITS to copy the files & directories to the share on2012MS
Get-Childitem $docs\Archive -Recurse  | 
ForEach-Object { Start-BitsTransfer -Source $_.fullname -Destination MyBackup:\$_ } 
