# Purpose: GetVolumeWithCredentials — Security auditing and compliance checks.
# ------------------------------------------------------------------------
# DATE: 1/8/2009
#
# KEYWORDS: Get-WmiObject, win32_volume
#
# COMMENTS: This script uses command line parameters
# to allow you to choose which computer, drive, and account
# to query for the Win32_Volume class. 
#
#
# ------------------------------------------------------------------------
Param(
      $drive = "C:", 
      $computer = "localhost",
      $credential
     )
Function Get-Volume($drive, $computer)
{
 $drive += "\\"
 Get-WmiObject -Class Win32_Volume -computerName $computer `
 -filter "Name = '$drive'"
} #end Get-Volume

Function Get-VolumeCredential($drive, $computer,$credential)
{
 $drive += "\\"
 Get-WmiObject -Class Win32_Volume -computerName $computer `
 -filter "Name = '$drive'" -credential $credential
} #end Get-VolumeCredential

# *** Entry point to script
If($computer -eq "localhost" -AND $credential) 
  { "Cannot use credential for local connection" ; exit }
Elseif ($computer -ne "localhost" -AND $credential)
  { 
   Get-VolumeCredential -Drive $drive -Computer $computer `
   -Credential $credential 
  }
Else
 { Get-Volume -Drive $drive -Computer $computer }
