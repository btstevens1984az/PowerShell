# ------------------------------------------------------------------------
# DATE: 5/3/2009
#
# KEYWORDS: PSDrive, Modules, Scope
#
# COMMENTS: This script creates two PSDrives: myMods
# and sysMods. These correspond to the users' modules
# folder and the system modules folder respectively. 
#
#
# ------------------------------------------------------------------------
Function New-ModuleDrives
{
<#
    .SYNOPSIS
    Creates two PSDrives: myMods and sysMods
    .EXAMPLE
    New-ModuleDrives
    Creates two PSDrives: myMods and sysMods. These correspond 
    to the user's Modules folder and the system Modules folder respectively. 
#>
 $driveNames = "myMods","sysMods"

 For($i = 0 ; $i -le 1 ; $i++)
 {
  New-PsDrive -name $driveNames[$i] -PSProvider filesystem `
  -Root ($env:PSModulePath.split(";")[$i]) -scope Global |
  Out-Null
 } #end For
} #end New-ModuleDrives

Function Get-FileSystemDrives
{
<#
    .SYNOPSIS
    Displays global PS Drives that use the filesystem provider
    .EXAMPLE
    Get-FileSystemDrives
    Displays global PS Drives that use the filesystem provider
#>
 Get-PSDrive -PSProvider fileSystem -scope Global
} #end Get-FileSystemDrives

# *** EntryPoint to Script ***
New-ModuleDrives
Get-FileSystemDrives
