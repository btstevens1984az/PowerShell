# Purpose: Push-Patch — Windows Update and patch management.
#----------------------------
#Forces a patch connect of machine passed in parameters
#
#Input: 
#    $ComputerName = hostname of target computer
#    $phx = flag to connect to core satellite server. If not specified the machine will connect to local fss server
#
#Usage: .\ pushPatch.ps1 <hostnames> ex: pushPatch.ps1 SJRDITS01 or pushPatch.ps1 SJRDITS01,155.47.37.242,207.64.52.71
#Also recommended usage: Get-Content hostnames.txt | ForEach-Object { pushPatch.ps1 $_}
#
#----------------------------
function Push-Patch {
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [String[]]$ComputerName,
        [switch]$CORE, #Flag to force connection to 114.148.18.125,
        [switch]$AGH, #Flag to force connection to 142.187.97.113,
        [switch]$BMH, #Flag to force connection to 69.22.90.253,
        [switch]$CHC, #Flag to force connection to 82.131.237.99,
        [switch]$COR, #Flag to force connection to 240.78.121.218,
        [switch]$CRH, #Flag to force connection to 43.37.221.116,
        [switch]$CSB, #Flag to force connection to 95.33.115.5,
        [switch]$DH, #Flag to force connection to 83.121.94.202,
        [switch]$FHC, #Flag to force connection to 138.57.82.1,
        [switch]$GMH, #Flag to force connection to 91.237.1.244,
        [switch]$MCM, #Flag to force connection to 161.170.74.154,
        [switch]$MET, #Flag to force connection to 52.95.109.93,
        [switch]$MFH, #Flag to force connection to 222.189.216.69,
        [switch]$MGC, #Flag to force connection to 129.234.15.198,
        [switch]$MGH, #Flag to force connection to 167.226.103.71,
        [switch]$MHB, #Flag to force connection to 218.17.155.199,
        [switch]$MMC, #Flag to force connection to 95.207.23.1,
        [switch]$MMR, #Flag to force connection to 78.5.248.223,
        [switch]$MMS, #Flag to force connection to 120.16.48.123,
        [switch]$MSH, #Flag to force connection to 58.179.182.33,
        [switch]$MSJ, #Flag to force connection to 250.171.29.116,
        [switch]$MTC, #Flag to force connection to 17.126.52.225,
        [switch]$NHC, #Flag to force connection to 83.58.67.63,
        [switch]$PAS, #Flag to force connection to 18.182.210.178,
        [switch]$134.45.36.238, #Flag to force connection to 119.223.48.126,
        [switch]$35.25.169.234, #Flag to force connection to 134.127.11.250,
        [switch]$160.238.111.221, #Flag to force connection to 214.193.3.93,
        [switch]$SAC, #Flag to force connection to 52.51.182.113,
        [switch]$SAC3, #Flag to force connection to SAC3-FSS-001,
        [switch]$SBM, #Flag to force connection to 147.253.123.154,
        [switch]$SEH, #Flag to force connection to 7.101.149.86,
        [switch]$SEQ, #Flag to force connection to 202.32.8.222,
        [switch]$SFH, #Flag to force connection to 195.47.238.174,
        [switch]$SJM, #Flag to force connection to 173.96.84.218,
        [switch]$SJR, #Flag to force connection to 142.232.49.251,
        [switch]$SJW, #Flag to force connection to 148.226.19.225,
        [switch]$SML, #Flag to force connection to 10.217.34.201,        
        [switch]$SMS, #Flag to force connection to 107.171.117.60,
        [switch]$SNM, #Flag to force connection to 237.97.63.121,
        [switch]$SRD, #Flag to force connection to 133.69.151.116,
        [switch]$SRM, #Flag to force connection to 122.249.122.63,
        [switch]$SRS, #Flag to force connection to 194.166.199.252,
        [switch]$WHC, #Flag to force connection to 104.2.42.171,
        [switch]$WMF, #Flag to force connection to 194.86.225.58,
        [switch]$restartServices, #Restart HPCA services in case computer is not responding
        [switch]$kill, #kill HPCA radpinit  in case computer is not responding
        [switch]$enableWindowsUpdate,
        [switch]$EWU
    )

    Foreach ($cn in $ComputerName) {
        write-debug $cn
        if ($restartServices) {
            Get-Service -DisplayName hpca* -ComputerName $cn |Restart-Service
        }
        if ($kill) {
            start-process taskkill.exe -ArgumentList "/s $cn  /fi `"imagename eq radconct*`" /f" -wait -NoNewWindow
            start-process taskkill.exe -ArgumentList "/s $cn  /fi `"imagename eq nvdkit*`" /f" -wait -NoNewWindow
            start-process taskkill.exe -ArgumentList "/s $cn  /fi `"imagename eq rad*`" /f" -wait -NoNewWindow
        }

        if ($enableWindowsUpdate -or $EWU) {
            Get-Service -DisplayName "Windows Update" -ComputerName $cn |start-Service
        }
        if ($CORE) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=114.148.18.125 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://114.148.18.125:3464,datauri=http://114.148.18.125:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($AGH) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=142.187.97.113 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://142.187.97.113:3464,datauri=http://142.187.97.113:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($BMH) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=69.22.90.253 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://69.22.90.253:3464,datauri=http://69.22.90.253:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($CHC) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=82.131.237.99 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://82.131.237.99:3464,datauri=http://82.131.237.99:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($COR) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=240.78.121.218 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://240.78.121.218:3464,datauri=http://240.78.121.218:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($CRH) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=43.37.221.116 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://43.37.221.116:3464,datauri=http://43.37.221.116:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($CSB) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=95.33.115.5 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://95.33.115.5:3464,datauri=http://95.33.115.5:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($DH) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=83.121.94.202 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://83.121.94.202:3464,datauri=http://83.121.94.202:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($FHC) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=138.57.82.1 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://138.57.82.1:3464,datauri=http://138.57.82.1:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($GMH) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=91.237.1.244 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://91.237.1.244:3464,datauri=http://91.237.1.244:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($MCM) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=161.170.74.154 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://161.170.74.154:3464,datauri=http://161.170.74.154:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($MET) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=52.95.109.93 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://52.95.109.93:3464,datauri=http://52.95.109.93:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($MFH) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=222.189.216.69 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://222.189.216.69:3464,datauri=http://222.189.216.69:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($MGC) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=129.234.15.198 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://129.234.15.198:3464,datauri=http://129.234.15.198:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($MGH) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=167.226.103.71 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://167.226.103.71:3464,datauri=http://167.226.103.71:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($MHB) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=218.17.155.199 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://218.17.155.199:3464,datauri=http://218.17.155.199:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($MMC) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=95.207.23.1 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://95.207.23.1:3464,datauri=http://95.207.23.1:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($MMR) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=78.5.248.223 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://78.5.248.223:3464,datauri=http://78.5.248.223:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($MMS) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=120.16.48.123 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://120.16.48.123:3464,datauri=http://120.16.48.123:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($MSH) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=58.179.182.33 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://58.179.182.33:3464,datauri=http://58.179.182.33:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($MSJ) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=250.171.29.116 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://250.171.29.116:3464,datauri=http://250.171.29.116:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($MTC) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=17.126.52.225 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://17.126.52.225:3464,datauri=http://17.126.52.225:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($NHC) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=83.58.67.63 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://83.58.67.63:3464,datauri=http://83.58.67.63:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($PAS) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=18.182.210.178 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://18.182.210.178:3464,datauri=http://18.182.210.178:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($134.45.36.238) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=248.85.59.40 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://248.85.59.40:3464,datauri=http://248.85.59.40:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($35.25.169.234) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=157.254.160.104 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://157.254.160.104:3464,datauri=http://157.254.160.104:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($160.238.111.221) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=254.154.30.117 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://254.154.30.117:3464,datauri=http://254.154.30.117:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
         if ($SAC) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=52.51.182.113 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://52.51.182.113:3464,datauri=http://52.51.182.113:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
        if ($SAC3) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=SAC3-FSS-001 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://SAC3-FSS-001:3464,datauri=http://SAC3-FSS-001:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
        if ($SBM) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=147.253.123.154 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://147.253.123.154:3464,datauri=http://147.253.123.154:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
        if ($SEH) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=7.101.149.86 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://7.101.149.86:3464,datauri=http://7.101.149.86:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
        if ($SEQ) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=202.32.8.222 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://202.32.8.222:3464,datauri=http://202.32.8.222:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
        if ($SFH) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=195.47.238.174 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://195.47.238.174:3464,datauri=http://195.47.238.174:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
        if ($SJM) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=173.96.84.218 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://173.96.84.218:3464,datauri=http://173.96.84.218:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
        if ($SJR) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=142.232.49.251 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://142.232.49.251:3464,datauri=http://142.232.49.251:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
        if ($SJW) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=148.226.19.225 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://148.226.19.225:3464,datauri=http://148.226.19.225:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
        if ($SML) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=10.217.34.201 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://10.217.34.201:3464,datauri=http://10.217.34.201:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
        if ($SMS) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=107.171.117.60 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://107.171.117.60:3464,datauri=http://107.171.117.60:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
        if ($SNM) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=237.97.63.121 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://237.97.63.121:3464,datauri=http://237.97.63.121:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
        if ($SRD) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=133.69.151.116 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://133.69.151.116:3464,datauri=http://133.69.151.116:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
        if ($SRM) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=122.249.122.63 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://122.249.122.63:3464,datauri=http://122.249.122.63:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
        if ($SRS) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=194.166.199.252 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://194.166.199.252:3464,datauri=http://194.166.199.252:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
        if ($WHC) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=104.2.42.171 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://104.2.42.171:3464,datauri=http://104.2.42.171:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
        if ($WMF) {
            Start-Process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman ip=194.86.225.58 port=3464,cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60,rcsuri=tcp://194.86.225.58:3464,datauri=http://194.86.225.58:3466"
        }
        else {
            start-process 'C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\radntfyc.exe' -ArgumentList "$cn radskman cat=prompt,ulogon=n,hreboot=n,dname=Patch,log=connect_Patch.log,rtimeout=60"
        }
    }
}

function Push-Patch-Parallel {
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [String]$InputObject,
        [switch]$kill
    )
    
    Invoke-Parallel -InputObject (Get-Content($InputObject)) -ScriptBlock {
        . "E:\WindowsPowerShell\Modules\Push-Patch.ps1";
        if ($kill) {
            push-patch $_ -kill
        }
        else {
            push-patch $_
        }
    } -Throttle 30 -runspacetimeout 40 
}