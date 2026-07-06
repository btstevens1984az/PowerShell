# Purpose: Get-RadiaServerServices — HP Radia client automation and satellite servers.
Function Get-RadiaServerServices {
param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [String[]]$ComputerName
    )

    $RCASatellite = Get-Service -ComputerName $ComputerName -DisplayName "RCA  Satellite"
    $RCAApacheServer = Get-Service -ComputerName $ComputerName -DisplayName "RCA Apache Server"
    $RCAApplicationServer = Get-Service -ComputerName $ComputerName -DisplayName "RCA Application Server"
    $RCACacheManager = Get-Service -ComputerName $ComputerName -DisplayName "RCA Cache Manager"
    $RCAConfigurationServer = Get-Service -ComputerName $ComputerName -DisplayName "RCA Configuration Server"
    $RCADBServer = Get-Service -ComputerName $ComputerName -DisplayName "RCA DB Server"
    $RCADistributedConfigurationServer = Get-Service -ComputerName $ComputerName -DisplayName "RCA Distributed Configuration Server"
    $RCAMessagingServer = Get-Service -ComputerName $ComputerName -DisplayName "RCA Messaging Server"
    $RCAMSIRedirector = Get-Service -ComputerName $ComputerName -DisplayName "RCA MSI Redirector"
    $RCANotifyDaemon = Get-Service -ComputerName $ComputerName -DisplayName "RCA Notify Daemon"
    $RCAPolicyServer = Get-Service -ComputerName $ComputerName -DisplayName "RCA Policy Server"
    $RCAProxyServer = Get-Service -ComputerName $ComputerName -DisplayName "RCA Proxy Server"
    $RCASchedulerDaemon = Get-Service -ComputerName $ComputerName -DisplayName "RCA Scheduler Daemon"

$RCASatellite
$RCAApacheServer
$RCAApplicationServer
$RCACacheManager
$RCAConfigurationServer
$RCADBServer
$RCADistributedConfigurationServer
$RCAMessagingServer
$RCAMSIRedirector
$RCANotifyDaemon
$RCAPolicyServer
$RCAProxyServer
$RCASchedulerDaemon

}