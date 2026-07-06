# Purpose: Fix-WindowsUpdate — Windows Update and patch management.
do{
    New-Item c:\LogUpdate.log -Force
    Clear-Host

    "======================================================================"
    "             Troubleshoot Windows Update Errors      "
    "======================================================================"
    "1. Deleting the Windows Update tempo"
    "2. Repairing the WU data bank"
    "3. Manipulation of network services"
    "4. Advanced WU Handling"
    "5. Quit the script"
    "======================================================================"

    $Valeur = Read-Host 
    Switch ($Valeur)
    {
        '1' {
                Add-Content -Encoding UTF8 -Path C:\LogUpdate.log -Value "***********************************************************"
                Add-Content -Encoding UTF8 -Path C:\LogUpdate.log -Value (get-date) -passthru
                Add-Content -Encoding UTF8 -Path C:\LogUpdate.log -Value "***********************************************************"
                Stop-Service -Name Bits, Wuauserv, Appidsvc, Cryptsvc -Force | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                Remove-Item "$env:ALLUSERSPROFILE\Application Data\Microsoft\Network\Downloader\qmgr*.dat" -Force | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                Start-Service -Name Bits, Wuauserv, Appidsvc, Cryptsvc | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
            
            }
        '2' {
                Add-Content -Encoding UTF8 -Path C:\LogUpdate.log -Value "***********************************************************"
                Add-Content -Encoding UTF8 -Path C:\LogUpdate.log -Value (get-date) -passthru
                Add-Content -Encoding UTF8 -Path C:\LogUpdate.log -Value "***********************************************************"
                Stop-Service -Name Bits, Wuauserv, Appidsvc, Cryptsvc -Force | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                Rename-Item $env:SystemRoot\SoftwareDistribution SoftwareDistribution.bak -Force | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                Rename-Item $env:SystemRoot\system32\catroot2 catroot2.bak -Force | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                Set-Location $env:SystemRoot\System32 | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe atl.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe urlmon.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe mshtml.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe shdocvw.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe browseui.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe jscript.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe vbscript.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe scrrun.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe msxml.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe msxml3.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe msxml6.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe actxprxy.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe softpub.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe wintrust.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe dssenh.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe rsaenh.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe gpkcsp.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe sccbase.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe slbcsp.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe cryptdlg.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe oleaut32.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe ole32.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe shell32.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe initpki.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe wuapi.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe wuaueng.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe wuaueng1.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe wucltui.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe wups.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe wups2.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe wuweb.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe qmgr.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe qmgrprxy.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe wucltux.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe muweb.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                regsvr32.exe wuwebv.dll | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                Start-Service -Name Bits, Wuauserv, Appidsvc, Cryptsvc | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
            }
        '3' {
                Add-Content -Encoding UTF8 -Path C:\LogUpdate.log -Value "***********************************************************"
                Add-Content -Encoding UTF8 -Path C:\LogUpdate.log -Value (get-date) -passthru
                Add-Content -Encoding UTF8 -Path C:\LogUpdate.log -Value 
                netsh winsock reset | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                netsh winhttp reset proxy | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                IPConfig -all | Select-String "IPv" | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                IPConfig -all | Select-String "Gat" | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log 
                Stop-Service -Name Bits, Wuauserv, Appidsvc, Cryptsvc -Force | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                Start-Service -Name Bits, Wuauserv, Appidsvc, Cryptsvc | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
            }
        '4' {
                Add-Content -Encoding UTF8 -Path C:\LogUpdate.log -Value "***********************************************************"
                Add-Content -Encoding UTF8 -Path C:\LogUpdate.log -Value (get-date) -passthru
                Add-Content -Encoding UTF8 -Path C:\LogUpdate.log -Value "***********************************************************"
                Stop-Service -Name Bits, Wuauserv, Appidsvc, Cryptsvc -Force | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                sfc /scannow | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
                Start-Service -Name Bits, Wuauserv, Appidsvc, Cryptsvc | Add-Content -Encoding UTF8 -Path C:\LogUpdate.log
            }
        '5' {
            $Valeur = 5
            Pause
            }
    }

}while ($Valeur -eq 0)