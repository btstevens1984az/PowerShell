# Purpose: 2-1 NewCmdlets — General-purpose PowerShell utilities.

###############################################################################
#setup
#set-location demopath
$DemoPath ='c:\temp\demos'
#New-PSDrive -Name Demos -PSProvider FileSystem -Root $DemoPath
#cd c:\temp\demos
#
#if (-not(Test-path c:\temp)){mkdir c:\temp}
#
#Clear-Host


###############################################################################
# Clipboard
#open folder and pick some files to copy to the clipboard
Invoke-Item .
Get-Clipboard -Format FileDropList

#Load helper function to convert email addresses to semicolon delimited format
. .\GetEmail.ps1

get-content .\EmailAddresses.csv | Get-Emailaddress  -Delimiter ';' | Set-Clipboard
notepad

#alternatively use Get-clipboard to select text from a file
#https://en.wikipedia.org/wiki/Email_address
Get-Clipboard  | Get-Emailaddress | Set-Clipboard

#Append to Clipboard 
get-content .\EmailAddresses.csv | Get-Emailaddress | Set-Clipboard -Append

#show html
Get-Clipboard -TextFormatType Html 

###############################################################################
# New-TemporaryFile
# NoNewLine

$temp = New-TemporaryFile
$temp

Add-Content -Path $temp -Value "Hello, world."
Add-Content -Path $temp -Value "Hello, world."
Add-Content -Path $temp -Value "Hello, world."
Add-Content -Path $temp -Value "Hello, world." -NoNewline
Add-Content -Path $temp -Value "Hello, world." -NoNewline
Add-Content -Path $temp -Value "Hello, world." -NoNewline

Get-Content -Path $temp

Get-Command -ParameterName NoNewLine

1..10 | ForEach-Object {Add-Content -Path $temp -Value "."}
1..10 | ForEach-Object {Add-Content -Path $temp -Value "." -NoNewline}

Get-Content -Path $temp

Remove-Item $temp

###############################################################################
# New-Guid

New-Guid

$g = New-Guid
$g | Get-Member
$g
$g.Guid
###############################################################################
# Get-ItemPropertyValue 
# Previous version technique
(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine").Powershellversion
#New Cmdlet
Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine" -Name Powershellversion
Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine" -Name Powershellversion,PSCompatibleVersion
###############################################################################
#Archive Files
 
Get-Module -Name Microsoft.PowerShell.Archive -ListAvailable
#Create an archive file
dir *.ps1 | Compress-Archive -DestinationPath test.zip -CompressionLevel Optimal -Verbose

#Add to an existing archive and/or replace older files in the archive with newer versions
dir *.csv | Compress-Archive -DestinationPath test.zip -CompressionLevel Optimal -Update -Verbose

mkdir .\temp
dir *.zip | Expand-Archive -DestinationPath .\temp -Verbose

#remove-item .\temp
###############################################################################
# Hex
Format-Hex -Path .\LogParser.zip
Format-Hex -Path '.\Windows Management Framework 5.0 Production Preview Release Notes.docx' | Select -First 50
Format-Hex -Path $Env:systemroot\System32\ping.exe | 
    Select-Object -First 5 # MZ Header - EXE

###############################################################################
#Recycle Bin
Clear-RecycleBin -DriveLetter c 
Clear-RecycleBin 

###############################################################################
#NetworkSwitchManager for Windows Server 2012 R2 logo-certified network switches
Get-Command -Module NetworkSwitchManager

###############################################################################
# Informational output stream
# New output stream
Write-Information -MessageData "This is a Information Message" -Tags "Information" -InformationAction Continue 

# Redirection of new Stream (6 = Information)
Write-Information -MessageData "Redirect me..." -Tags "Information" 6> $DemoPath\InfoStream.txt

#Can now redirect write-host
Write-Host "test" 6> c:\temp\test.txt

$InformationPreference

#new Common Parameters
Write-Host "Output is still sent to the host but also the information output stream" -InformationVariable var 
Write-Information "you won't see this" 
Write-Information "you will now see this" -InformationAction Continue 
###############################################################################
# Copy-Item To/From PSSession
$TargetComputer = "testsrv1"
$PSSession = New-PSSession -ComputerName $TargetComputer

Invoke-Command -Session $PSSession -ScriptBlock {del c:\temp -Recurse}
Invoke-Command -Session $PSSession -ScriptBlock {md c:\temp\}
Invoke-Command -Session $PSSession -ScriptBlock {dir c:\temp\}

measure-command {Copy-Item -Path .\LogParser.zip -Destination C:\Temp -ToSession $PSSession -Verbose}
Measure-Command {copy-item .\LogParser.zip \\$TargetComputer\c$\temp -Force}
#notice the performance difference. For small files this is fine but larger files would not be optimal.
Invoke-Command -Session $PSSession -ScriptBlock {dir c:\temp}

#Copy From Session
Copy-Item -Path C:\Temp -Destination C:\temp -FromSession $PSSession -Verbose -Recurse -Force

Remove-PSSession $PSSession

###############################################################################
#Import-PowerShellDataFile
Import-PowerShellDataFile -Path .\testmanifest.psd1
###############################################################################
#Optional Demos
<#
$s = gcm ConvertFrom-SddlString
$s.Definition

$acl = Get-Acl c:\temp
ConvertFrom-SddlString $acl.Sddl -Type FileSystemRights

$ADSddl = Invoke-Command -ComputerName 201.72.64.23 -ScriptBlock {(Get-ADOrganizationalUnit "ou=domain controllers,dc=kaylos,dc=lab" -Properties *).nTSecurityDescriptor.sddl} 
$s = ConvertFrom-SddlString  -SDDL $ADSddl -Type ActiveDirectoryRights 
$s.DiscretionaryAcl
#>