# Purpose: Get-LargeAddressAwareExe — General-purpose PowerShell utilities.

Function Get-LargeAddressAwareExe
{
[cmdletbinding()]
param($path ='C:\Program Files (x86)\Mozilla Firefox\firefox.exe' )
dir -Path $path -Recurse -Include *.exe | %{ 
$results = dumpbin $_.fullname /headers
    if ($results -match 'Application can handle large \(>2GB\) addresses')
    {
    Write-Verbose "The following is Large Address Aware: $($_.fullname)"
        $_
    }
    }
 }


