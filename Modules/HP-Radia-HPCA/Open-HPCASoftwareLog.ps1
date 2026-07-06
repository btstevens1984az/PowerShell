# Purpose: Open-HPCASoftwareLog — HP Radia client automation and satellite servers.
Function Open-HPCASoftwareLog {
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]$ComputerName,
        [switch]$Website #Flag to open patch stats site
  
    )

    if(Test-Connection $ComputerName -count 1 -Quiet)
    { 
        Invoke-Item "\\$ComputerName\c$\Program Files (x86)\Hewlett-Packard\HPCA\Agent\Log\connect_software.log"
        Invoke-Item "\\$ComputerName\c$\Program Files (x86)\Hewlett-Packard\HPCA\Agent\Log\connect_software.log" -ErrorAction SilentlyContinue

        if($Website){
            Invoke-Item "\\$ComputerName\c$\Program Files\Hewlett-Packard\HPCA\Agent\Lib\patch_stats.html"
            Invoke-Item "\\$ComputerName\c$\Program Files (x86)\Hewlett-Packard\HPCA\Agent\Lib\patch_stats.html" -ErrorAction SilentlyContinue
        }
    }
    else
    {
      write-host "$ComputerName is offline"
    }
}