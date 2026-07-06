# Purpose: Delete-PatchData — Windows Update and patch management.
#----------------------------
#Delete patch and data folders in HPCA and force a patch connect
#
#Input: 
#$ComputerName = hostname of target computer
#$phx = flag to connect to core satellite server. If not specified the machine will connect to local fss server
#
#Usage: delete-PatchData.ps1 <hostnames> ex: pushPatch.ps1 SJRDITS01 or pushPatch.ps1 SJRDITS01,114.148.18.125,119.223.48.126
#Also recommended usage: Get-Content hostnames.txt | ForEach-Object { pushPatch.ps1 $_}
#
#----------------------------
function Delete-PatchData{
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String[]]$ComputerName
        
    )

    Foreach($cn in $ComputerName)
    {
	    try{
    
   
        if(Test-Path "\\$cn\c$\Program Files (x86)\Hewlett-Packard\HPCA\Agent\Lib\SYSTEM\RADIA\PATCH\ZSERVICE\DISCOVER_PATCH"){

            Remove-Item "\\$cn\c$\Program Files (x86)\Hewlett-Packard\HPCA\Agent\Lib\SYSTEM\RADIA\PATCH\ZSERVICE\DISCOVER_PATCH" -Recurse -Force
            Remove-Item "\\$cn\c$\Program Files (x86)\Hewlett-Packard\HPCA\Agent\Lib\SYSTEM\RADIA\PATCH\ZSERVICE\FINALIZE_PATCH" -Recurse -Force
            }
        elseif(Test-Path "\\$cn\c$\Program Files\Hewlett-Packard\HPCA\Agent\Lib\SYSTEM\RADIA\PATCH\ZSERVICE\DISCOVER_PATCH"){
				
			Remove-Item "\\$cn\c$\Program Files\Hewlett-Packard\HPCA\Agent\Lib\SYSTEM\RADIA\PATCH\ZSERVICE\DISCOVER_PATCH" -Recurse -Force
			Remove-Item "\\$cn\c$\Program Files\Hewlett-Packard\HPCA\Agent\Lib\SYSTEM\RADIA\PATCH\ZSERVICE\FINALIZE_PATCH" -Recurse -Force
            }

        New-Object psobject -Property @{
                    ComputerName = $cn
                    ErrorCode= Removed
                    }
    }catch{
        New-Object psobject -Property @{
                    ComputerName = $cn
                    ErrorCode= "Could not open log"
                    }
        }
    }
}