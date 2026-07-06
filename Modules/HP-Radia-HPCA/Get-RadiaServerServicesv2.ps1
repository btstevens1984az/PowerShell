# Purpose: Get-RadiaServerServicesv2 — HP Radia client automation and satellite servers.
Function Get-RadiaServerServicesv2 {
param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [String[]]$ComputerName
    )

Get-Service -ComputerName $ComputerName -Name "RCA  Satellite", "RCA Apache Server", "RCA Application Server", "RCA Cache Manager", "RCA Configuration Server", "RCA DB Server", "RCA Distributed Configuration Server", "RCA Messaging Server", "RCA MSI Redirector", "RCA Notify Daemon", "RCA Policy Server", "RCA Proxy Server", "RCA Scheduler Daemon" | Where-Object -Property Status -ne "Running" | Format-Table -HideTableHeaders -Property Name
}