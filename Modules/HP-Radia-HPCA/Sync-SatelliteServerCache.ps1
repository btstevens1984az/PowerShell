# Purpose: Sync-SatelliteServerCache — HP Radia client automation and satellite servers.
#############################################################
#
# Overview:         Function to Synchronize Satellite Servers
# Date Created:     02/26/2018
# Function Name:    SyncData-SatelliteServer
# 
#############################################################

Function Sync-SatelliteServerCache {
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [String[]]$Server
        )
Invoke-WebRequest -Uri "http://$Server.example.com:3466/proc/rps/sync#"
}

