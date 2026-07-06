# Purpose: CreateRegistryKey — Windows registry read and write operations.
﻿# -----------------------------------------------------------------------------
# CreateRegistryKey.ps1
# ed wilson, msft, 8/21/2009
# creates a registry key
# Windows PowerShell Best Practices
# ----------------------------------------
Function Add-RegistryValue($key,$value)
{
 $scriptRoot = "HKCU:\software\ForScripting"
 if(-not (Test-Path -path $scriptRoot))
   { 
    New-Item -Path HKCU:\Software\ForScripting | Out-null 
    New-ItemProperty -Path $scriptRoot -Name $key -Value $value `
    -PropertyType String | Out-Null
    }
  Else
  {
   Set-ItemProperty -Path $scriptRoot -Name $key -Value $value | `
   Out-Null
  }
  
} #end function Add-RegistryValue

# *** Entry Point to Script ***
Add-RegistryValue -key forscripting -value test