# Purpose: Get-ScriptVersion — General-purpose PowerShell utilities.
﻿
# -----------------------------------------------------------------------------
# Get-ScriptVersion.ps1
# ed wilson, msft
# LASTEDIT: 8/8/2009
# VERSION: 1.0.0
# This script relies upon having a LASTEDIT: and a VERSION: tag in the 
# header of the script.
#
# -----------------------------------------------------------------------------

function get-ScriptVersion ([string]$path)
{
 $scripts = Get-ChildItem -Path $path -recurse
 ForEach($script in $scripts)
 { 
  $info = New-Object psobject
  $scriptText = Get-Content $script.fullname 
  $info | 
  Add-Member -Name "name" -Value $script.name -MemberType noteproperty
  $lastedit = $scriptText | 
  Select-String -Pattern "\s\d{1,1}/\d{1,2}/\d{1,4}"
  
  if($lastedit.count -gt 1)
   {
     $info | 
     Add-Member -Name "LastEdit" -Value $lastedit[0].matches[0].value `
     -membertype noteproperty
   }
  if($lastedit.matches.count -gt 0)
   { 
    $info | 
    Add-Member -Name "LastEdit" -Value $lastedit.matches[0].value `
    -membertype noteproperty 
   }
  $version =  $scriptText | 
  Select-String -Pattern "\s\d\.\d\.\d"
  
  if($version.count -gt 1)
   {
    $info | 
    Add-Member -Name version -Value $version[0].matches[0].value `
    -membertype noteproperty
   }
  if($version.matches.count -gt 0)
   {
    $info | 
    Add-Member -Name version -Value $version.matches[0].value `
    -membertype noteproperty
   }
  $info 
  $version = $lastedit = $scriptText = $null
 } #end foreach
} #end function get-ScriptVersion

# *** Entry Point ***

Get-ScriptVersion -path C:\W7_ResKitScripts\Chapter1| 
Format-Table -Property * -AutoSize