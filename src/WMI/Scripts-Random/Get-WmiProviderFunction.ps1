# Purpose: Get-WmiProviderFunction — PowerShell automation.
# ------------------------------------------------------------------------
# DATE: 7/7/2009
#
# KEYWORDS: Function, Wmi Provider, Test-Path,
# Join-Path, New-PsDrive, Write-Verbose
# COMMENTS: This script contains the Get-WmiProvider
# function that can be used to ensure that a wmi provider is
# installed, and registered with DCOM. It is best used to ensure
# that a WMI Provider exists prior to calling it. This function
# returns a true or a false depending on the existence of
# the wmi provider.
#
# ------------------------------------------------------------------------
Function Get-WmiProvider([string]$providerName, [switch]$verbose)
{
 $oldVerbosePreference = $VerbosePreference
 if($verbose) { $VerbosePreference = "continue" }
 $provider =  Get-WmiObject -Class __provider -filter "name = '$providerName'"
 If($provider -ne $null)
   {
    $clsID = $provider.clsID
    Write-Verbose "$providerName WMI provider found. ClsID is $($clsID)"
   }
 Else 
   {
     Return $false
   }
   Write-Verbose "Checking for proper registry registration ..."
   If(Test-Path -path HKCR:)
      {
        Write-Verbose "HKCR: drive found. Testing for $clsID"
        Test-path -path (Join-Path -path HKCR:\CLSID -childpath $clsID)  
      }
   Else
     {
      Write-Verbose "HKCR: drive not found. Creating same." 
      New-PSDrive -Name HKCR -PSProvider registry -Root Hkey_Classes_Root | Out-Null
      Write-Verbose "Testing for $clsID" 
      Test-path -path (Join-Path -path HKCR:\CLSID -childpath $clsID)  
      Write-Verbose "Test complete."
      Write-Verbose "Removing HKCR: drive." 
      Remove-PSDrive -Name HKCR | Out-Null
     }
  $VerbosePreference = $oldVerbosePreference
} #end Get-WmiProvider function

# *** Entry Point to Script ***
$providerName = "cimwin32"
 if(Get-WmiProvider -providerName $providerName  -verbose ) 
  { 
    Get-WmiObject -class win32_bios 
  } 
else 
  { 
   "$providerName provider not found" 
  }