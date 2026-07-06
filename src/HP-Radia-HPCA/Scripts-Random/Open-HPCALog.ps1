# Purpose: Open-HPCALog — HP Radia client automation and satellite servers.
function Open-HPCALog{
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]$cn,
        [switch]$w #Flag to open patch stats site
  
    )

    if(Test-Connection $cn -count 1 -Quiet)
    { 
        Invoke-Item "\\$cn\c$\Program Files\Hewlett-Packard\HPCA\Agent\Log\connect_Patch.log"
        Invoke-Item "\\$cn\c$\Program Files (x86)\Hewlett-Packard\HPCA\Agent\Log\connect_Patch.log" -ErrorAction SilentlyContinue

        if($w){
            Invoke-Item "\\$cn\c$\Program Files\Hewlett-Packard\HPCA\Agent\Lib\patch_stats.html"
            Invoke-Item "\\$cn\c$\Program Files (x86)\Hewlett-Packard\HPCA\Agent\Lib\patch_stats.html" -ErrorAction SilentlyContinue
        }
    }
    else
    {
      write-host "$cn is offline"
    }
}