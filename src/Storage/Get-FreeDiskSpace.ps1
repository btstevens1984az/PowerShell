# Purpose: Get-FreeDiskSpace — Storage management and disk operations.
# --------------------------------------------------------------------------
# Get-FreeDiskSpace.ps1
# ed wilson, msft, 2/20/2009
# for help Get-FreeDiskSpace -full
# the requires version must not have a space between the #
#requires -Version 2.0
# --------------------------------------------------------------------------

Function Get-FreeDiskSpace
{
 <#
   .Synopsis
      Returns free disk space from one or more hard drives 
 from local or remote computer
   .Description
      This function accepts drive and computer name and
 returns amount of free disk space in Megabytes
  .Parameter drive
     The drive from which to return free disk space
  .Parameter computer
     The computer from which the data is to be returned
  .Example
     Get-FreeDiskSpace -drive c: -computer 157.217.58.110
     This example returns the free disk space from the c: 
     drive on a remote computer named berlin
  .Example
     Get-FreeDiskSpace -all -computer 157.217.58.110
     This example returns free disk space from all drives
     on a remote computer named berlin
  .Example
     Get-FreeDiskSpace c:
     This example returns free disk space from the c:
     drive on the local computer
  .Example
    Get-FreeDiskSpace
    This example returns free disk space from the c:
    drive on the local computer
  .Inputs 
   [String]
  .Outputs
   [String]
    Name: Get-FreeDiskSpace
    Book: Windows PowerShell Best Practices, Microsoft Press, 2009
    Version: 1.0
    Date: 2/21/2009
  .Link
   Get-WmiObject
   Http://www.ScriptingGuys.Com
 #>

 Param (
               [Parameter(
                   Mandatory=$true,
                   ValueFromPipelineByPropertyName=$false)]
                   [string]$drive="C:",
               $computer=$env:Computername,
               [Switch]$all 
             )
 if($all)
   {
    Get-WmiObject -class win32_LogicalDisk `
 -computername $computer -filter "DriveType = 3" |
   ForEach-Object {
"
 $computer free disk space on drive $($_.Name) 
 $("{0:n2}" -f ($_.FreeSpace/1MB)) MegaBytes
" 
  } #end foreach
  $drive = $null
  }#end If all
if($drive)
   {
    $driveData = Get-WmiObject -class win32_LogicalDisk `
    -computername $computer -filter "Name = '$drive'" 
   "
    $computer free disk space on drive $drive 
       $("{0:n2}" -f ($driveData.FreeSpace/1MB)) MegaBytes
   "
   } #end if
} #end Get-FreeDiskSpace

Get-FreeDiskSpace