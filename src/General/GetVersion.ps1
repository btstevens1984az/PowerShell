# Purpose: GetVersion — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 12/31/2008
#
# KEYWORDS: Win32_OperatingSystem,
# reference, pass by reference, WMI, function,
# 
# COMMENTS: This script uses one function. The first
# function is used to determine the version of the OS. 
#
# ------------------------------------------------------------------------
Param($computer = "localhost")

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

# *** entry point to script ***
$osv = $null
Get-OSVersion -computer $computer -osv ([ref]$osv)
$osv
