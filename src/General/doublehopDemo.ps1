# Purpose: doublehopDemo — General-purpose PowerShell utilities.
workflow test
{
    param ($computerName)
   
   Foreach –parallel ($comp in $computerName)
   {
    
    inlinescript {
        
        #Start-Sleep -Seconds 5
     Get-wmiobject -ClassName win32_operatingsystem | Select-Object __server,caption
     test-path "\\190.113.222.206\d$\isos"
     
     } -PSComputerName $comp
     Get-WmiObject -Class Win32_bios | Select-Object __server
     test-path "\\190.113.222.206\d$\isos"
     }
}

workflow test2 {
    Get-WmiObject -Class Win32_bios | Select-Object __server
     test-path "\\190.113.222.206\d$\isos"

}

test2 -PSComputerName pkiroot -PSAuthentication Credssp -PSCredential (Get-Credential)