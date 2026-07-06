# Purpose: Configure-CreateADSubnets — Network diagnostics, DNS, DHCP, and connectivity.
<#
Solution: Hydration
Purpose: Used to create AD Sites and Subnets
Version: 1.2 - January 10, 2013

This script is provided "AS IS" with no warranties, confers no rights and 
is not supported by the authors or Deployment Artist. 

    Twitter: @jarwidmark
    Blog   : http://deploymentresearch.com
#>


# Determine where to do the logging 
$tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment 
$logPath = $tsenv.Value("LogPath") 
$logFile = "$logPath\$($myInvocation.MyCommand).log" 

# Start the logging 
Start-Transcript $logFile 
Write-Host "Logging to $logFile" 

# Create Empty AD Sites (sites with no domain controllers, for lab purpose only)
New-ADReplicationSite -Name Stockholm
New-ADReplicationSite -Name Liverpool

# Create AD Subnets 
New-ADReplicationSubnet -Name "201.195.50.33/24" -Site NewYork
New-ADReplicationSubnet -Name "33.171.93.54/24" -Site Stockholm
New-ADReplicationSubnet -Name "8.240.212.188/24" -Site Liverpool

# Stop logging 
Stop-Transcript

