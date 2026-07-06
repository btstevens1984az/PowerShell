# Purpose: Get-NICinfov2 — Network diagnostics, DNS, DHCP, and connectivity.
$computers ='kms','vmhost5','vmhost4'
function Get-NicInfo
{
    param(
    [Parameter(
                Mandatory=$true, 
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true
                )]
        [Alias("__server","hostname","ServerName","Computer")] 
    [string[]]$computerName = "localhost"
    )
begin {
    $IPv4Pattern = "\b(25[0-4]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b"
    }

process {
$nicreport = foreach($computer in $computerName)
    {
    Write-Verbose "Querying nic info on $computer"
    $nicinfo = Get-WmiObject -Class win32_networkadapterconfiguration -ComputerName $computer -Filter {ipenabled = true}
    $multihomed = $false
    if ($nicinfo.count -gt 1)
    {
        $multihomed = $true
    }
    foreach ($nic in $nicinfo)
    {
        $multiIPs = $false
        $ipv4Count = 0
        if ($nic.ipaddress.count -gt 1)
        {
            foreach($IPv4 in $nic.ipaddress)
            {
                if ($ipv4 -match $IPv4Pattern)
                {$ipv4Count++ }          
            }
            If ($ipv4Count -gt 1)
            {
                $multiIPs= $true
            }
        }
        $propMultiIPs = @{
                            name="MultiIPV4s"
                            expression = {$multiIPs}
                        }
        $propMultiHomed = @{
                            name="Multihomed"
                            expression = {$multihomed}
                        }

        $nic | Select-Object __Server,Ipaddress,MACAddress,DNSServerSearchOrder,$propMultiIPs,$propMultiHomed

    }
    
    #$nicinfo | Select-Object __server,IPaddress,MACAddress,DNSServerSearchOrder

}


    $nicreport
}

End { 
        Write-verbose "Exiting Function Get-NicInfo"
    }
}
$computers | Get-NicInfo | Out-GridView
