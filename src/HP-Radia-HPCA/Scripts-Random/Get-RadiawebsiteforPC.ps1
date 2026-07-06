# Purpose: Get-RadiawebsiteforPC — HP Radia client automation and satellite servers.
Function Get-RadiawebsiteforPC {
param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [String[]]$ComputerName
    )

$url = "http://114.148.18.125:3466/rrs/results.tcl?repRole=DEF&setview=RAMDeviceDetails_WBEM.view&RAM%20Device%20ID.filter="$ComputerName"&"

Invoke-WebRequest $url -OutFile -
}