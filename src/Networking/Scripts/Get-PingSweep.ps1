# Purpose: Get-PingSweep — Network diagnostics, DNS, DHCP, and connectivity.
    Function Get-PingSweep {
    $objWOLInfo = [ordered]@{}
    $objWOLInfo.ClientIP = $ComputerName
    #$objWOLInfo.ClientName = $InputObject.ClientName
    #$objWOLInfo.MacAddress = $InputObject.MacAddress
    if (Test-Connection -ComputerName $ComputerName -BufferSize 16 -Count 1 -Quiet -ErrorAction SilentlyContinue) {
        $objWOLInfo.Online = $true
    }
    else {
        $objWOLInfo.Online = $false
    }
    $objWOLInfo
    }