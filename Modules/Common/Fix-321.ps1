# Purpose: Fix-321 — Reusable PowerShell function libraries.
#Fix for exit code 321. Delete Discover_Patch folder in HPCA and force a patch connect
#
#Input: 
#    $ComputerName = hostname of target computer
#    $phx = flag to connect to 114.148.18.125 server. If not specified the machine will connect to local Radia server
#
#Example:
#    Fix-321 CRHZMED525, Fix-321 SSODMMG57 -CoreSatellite
#function Fix-ZTime
#----------------------------
function Fix-321 {
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String[]]$ComputerName,
        [switch]$CoreSatellite, #Flag to force connection to RCA Core
        [switch]$kill #kill HPCA radpinit  in case computer is not responding
    )

    foreach($ComputerName in $ComputerNames)
        {
        if($kill){
            start-process taskkill.exe -ArgumentList "/s $ComputerName  /fi `"imagename eq rad**`" /f" -wait -NoNewWindow
		    start-process taskkill.exe -ArgumentList "/s $ComputerName  /fi `"imagename eq nvdkit*`" /f" -wait -NoNewWindow
	    }
        {
        if(Test-Path "\\$ComputerName\c$\_RESOURCE\patch"){
            Copy-Item \\186.189.182.154\share'&'Auto\RCA\PowerShell\WPS\BatchFiles\DEL_DiscPatch.bat \\$ComputerName\c$\_RESOURCE\patch\ -Force
        }
        else{
            New-Item \\$ComputerName\c$\_RESOURCE\patch -type directory
            Copy-Item \\186.189.182.154\share'&'Auto\RCA\WPS\BatchFilesDEL_DiscPatch.bat -destination \\$ComputerName\c$\_RESOURCE\patch\ -Force
        }

        PsExec -s \\$ComputerName "c:\_RESOURCE\patch\DEL_DiscPatch.bat"

        if($CoreSatellite){
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$ComputerName radskman ip=119.223.48.126,port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://114.148.18.125:3464,datauri=http://114.148.18.125:3466"
        }
                        
        else{
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$ComputerName radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
      }
    }
}