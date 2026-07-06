# Purpose: Fix-ZTime — Reusable PowerShell function libraries.
﻿function Fix-ZTime{
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String[]]$ComputerName,
        [switch]$kill #kill HPCA radpinit  in case computer is not responding
    )

    Foreach($ComputerName in $ComputerNames)
    {
        if($kill){
            start-process taskkill.exe -ArgumentList "/s $ComputerName  /fi `"imagename eq rad**`" /f" -wait -NoNewWindow
		    start-process taskkill.exe -ArgumentList "/s $ComputerName  /fi `"imagename eq nvdkit*`" /f" -wait -NoNewWindow
            
	    }


        if(Test-Path "\\$ComputerName\c$\Program Files (x86)\Hewlett-Packard\HPCA\Agent\Lib\ZTIMEQ.EDM")
            {
            
                $WriteTime= Get-Item -Path "\\$ComputerName\c$\Program Files (x86)\Hewlett-Packard\HPCA\Agent\Lib\ZTIMEQ.EDM" | Select LastWriteTime
                Write-Host $ComputerName $WriteTime
                Remove-Item -Path "\\$ComputerName\c$\Program Files (x86)\Hewlett-Packard\HPCA\Agent\Lib\ZTIMEQ.EDM" -Force
            }
        else
            {
            
                $WriteTime= Get-Item -Path "\\$ComputerName\c$\Program Files\Hewlett-Packard\HPCA\Agent\Lib\ZTIMEQ.EDM" | Select LastWriteTime
                Write-Host $ComputerName $WriteTime
                Remove-Item -Path "\\$ComputerName\c$\Program Files\Hewlett-Packard\HPCA\Agent\Lib\ZTIMEQ.EDM" -Force
            }
    
        start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$ComputerName radskman cat=prompt,ulogon=n,hreboot=n,dname=Software,log=connect_Software.log,rtimeout=60"
       
    }
}