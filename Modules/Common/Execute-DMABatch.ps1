# Purpose: Execute-DMABatch — Reusable PowerShell function libraries.
#############################################################
#
# Overview:         Function to Synchronize Satellite Servers
# Date Created:     02/28/2018
# Function Name:    Execute-DMABatch
# 
#############################################################

Function Execute-DMABatch {
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [String[]]$SatelliteServer
        )

            start-process -filepath "\\$SatelliteServer\e$\PSL\RCA\dcs\dmabatch.exe"
}