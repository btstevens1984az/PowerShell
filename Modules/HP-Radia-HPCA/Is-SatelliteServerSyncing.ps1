# Purpose: Is-SatelliteServerSyncing — HP Radia client automation and satellite servers.
#############################################################
# Overview:         Function to Synchronize Satellite Servers
# Date Created:     02/27/2018
# Function Name:    Is-SatelliteServerSyncing
#############################################################

Function Is-SatelliteServerSyncing {

$SatelliteServers = get-content "U:\Functions\BothTier1and2ServersNoCore.txt"

foreach ($SatelliteServer in $SatelliteServers)
{
    
if (Test-Path \\$SatelliteServer\e$\PSL\RCA\ApacheServer\apps\console\etc\sync.pid)
    {
    $FileDate = (Get-ChildItem \\$SatelliteServer\e$\PSL\RCA\ApacheServer\apps\console\etc\sync.pid).CreationTime

    "$SatelliteServer | $FileDate"
    }
    else
    {
    "$SatelliteServer | Server is not syncing"
    }
}
}