# Purpose: Push-Software — Reusable PowerShell function libraries.
function Push-Software{
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String[]]$ComputerName,
        [switch]$restartServices, #Restart HPCA services in case computer is not responding
        [switch]$kill, #kill HPCA radpinit  in case computer is not responding
	    [switch]$CoreSatellite, #Flag to force connection to 75.87.199.36
        [switch]$l #Open the log
    )

    Foreach($ComputerName in $ComputerNames)
    {
        write-debug $ComputerName
        if($restartServices){
		    Get-Service -DisplayName hpca* -ComputerName $ComputerName |Restart-Service
	    }
	    if($kill){
            start-process taskkill.exe -ArgumentList "/s $ComputerName  /fi `"imagename eq radconct*`" /f" -wait -NoNewWindow
		    start-process taskkill.exe -ArgumentList "/s $ComputerName  /fi `"imagename eq nvdkit*`" /f" -wait -NoNewWindow
        }

	    if($CoreSatellite){
		    start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$ComputerName radskman ip=224.141.8.107,port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Software,log=connect_Software.log,rtimeout=60"
		    }
	    else{
            start-process 'C:\Program Files\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$ComputerName radskman cat=prompt,ulogon=n,hreboot=n,dname=Software,log=connect_Software.log,rtimeout=60"		    
            }
        if($l){
            Invoke-Item "\\$ComputerName\c$\Program Files (x86)\Hewlett-Packard\HPCA\Agent\Log\connect_Software.log"
        }
    }
}