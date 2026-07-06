# Purpose: GetVersionGetVolume — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 12/31/2008
#
# KEYWORDS: Win32_volume, Win32_OperatingSystem,
# reference, pass by reference, WMI, function,
# multiple parameters
# COMMENTS: This script uses two functions. The first
# function is used to determine the version of the OS. 
# The second function uses Win32_Volume to obtain disk
# information. The Win32_Volume wmi class does not 
# exist on Windows XP.
#
# ------------------------------------------------------------------------
Param($drive = "C:", $computer = "localhost")

Function Get-OSVersion($computer,[ref]$osv)
{
 $os = Get-WmiObject -class Win32_OperatingSystem `
           -computerName $computer
Switch ($os.Version)
  {
    "5.1.2600" { $osv.value = "xp" }
    "5.1.3790" { $osv.value = "2003" }
    "6.0.6001" 
                     {
                       If($os.ProductType -eq 1)
                          {
                            $osv.value = "Vista"
                          } #end if
                       Else
                         {
                           $osv.value = "2008"
                          } #end else
                     } #end 6001
     DEFAULT { "Version not listed" }
  } #end switch
} #end Get-OSVersion

Function Get-Volume($drive, $computer)
{
 $drive += "\\"
 Get-WmiObject -Class Win32_Volume -computerName $computer `
 -filter "Name = '$drive'"
} #end Get-Volume

# *** entry point to script ***
$osv = $null
Get-OSVersion -computer $computer -osv ([ref]$osv)
if($osv -eq "xp") { "Script does not run on XP" ; exit }
Get-Volume -Drive $drive -Computer $computer