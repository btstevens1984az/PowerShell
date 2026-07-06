# Purpose: Test-ModulePath — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 2/20/2009
#
# KEYWORDS: modules, test-path, new-item, environment
#
# COMMENTS: This script looks for the module path folder
# on either xp family or vista family computer. if the module
# folder is missing, it will create it.
#
# PowerShell Best Practices
# ------------------------------------------------------------------------
Function Get-OperatingSystemVersion
{
 (Get-WmiObject -Class Win32_OperatingSystem).Version
} #end Get-OperatingSystemVersion

Function Test-ModulePath
{
 $VistaPath = "$env:userProfile\documents\WindowsPowerShell\Modules"
 $XPPath =  "$env:Userprofile\my documents\WindowsPowerShell\Modules" 
 if ([int](Get-OperatingSystemVersion).substring(0,1) -ge 6) 
   { 
     if(-not(Test-Path -path $VistaPath))
       {
         New-Item -Path $VistaPath -itemtype directory
       } #end if
   } #end if
 Else 
   {  
     if(-not(Test-Path -path $XPPath))
       {
         New-Item -path $XPPath -itemtype directory
       } #end if
   } #end else
} #end Test-ModulePath

Test-ModulePath
