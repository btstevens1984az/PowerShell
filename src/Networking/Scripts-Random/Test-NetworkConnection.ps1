# Purpose: Test-NetworkConnection — Network diagnostics, DNS, DHCP, and connectivity.
﻿Function Test-NetworkConnection
{
 $wmi = Get-WmiObject -Class win32_networkadapter `
        -Filter "NetConnectionStatus = 2"
 if(($wmi | Measure-Object).count) { $true } else { $false }
} #end function test-NetworkConnection

# *** Entry Point to Script *** 

If (-not(Test-NetworkConnection)) 
  { Write-Host -ForegroundColor red "A network connection is required for this script" ; exit }