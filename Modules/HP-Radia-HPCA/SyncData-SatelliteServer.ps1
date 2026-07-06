# Purpose: SyncData-SatelliteServer — HP Radia client automation and satellite servers.
#############################################################
#
# Overview:         Function to Synchronize Satellite Servers
# Date Created:     02/26/2018
# Function Name:    SyncData-SatelliteServer
# 
#############################################################

Function SyncData-SatelliteServer{
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [String[]]$SatelliteServer

Invoke-WebRequest -Uri "http://$SatelliteServer.example.com:3466/sm?console=operations_console#"
}

