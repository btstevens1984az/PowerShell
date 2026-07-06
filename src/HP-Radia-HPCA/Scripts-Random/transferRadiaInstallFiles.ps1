# Purpose: transferRadiaInstallFiles — HP Radia client automation and satellite servers.
 function transferRadiaInstallFiles
{
 Invoke-Parallel -InputObject $(get-content .\copylist.txt) -ScriptBlock {
            copy-item -path "E:\Share\win32" -destination "\\$_\c$\_resource\win32" -Force -recurse 
    } -Throttle 1000 -runspacetimeout 10000
    
    }