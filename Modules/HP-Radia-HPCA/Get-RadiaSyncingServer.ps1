# Purpose: Get-RadiaSyncingServer — HP Radia client automation and satellite servers.
Function Get-RadiaSyncingServer {
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [String[]]$ComputerName
    )
            $Proxy = Get-Content "\\$ComputerName\E$\PSL\RCA\ProxyServer\etc\rps.cfg" | Where-Object {$_ -like '*.example.com*'}
            $ProxyApache = Get-Content "\\$ComputerName\E$\PSL\RCA\ApacheServer\apps\proxy\etc\proxy.cfg" | Where-Object {$_ -like 'example.com:3464*'}
            Write-Host "$ComputerName $Proxy $ProxyApache"
}