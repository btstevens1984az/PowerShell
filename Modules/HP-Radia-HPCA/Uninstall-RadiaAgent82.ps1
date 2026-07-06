# Purpose: Uninstall-RadiaAgent82 — HP Radia client automation and satellite servers.
Function Uninstall-RadiaAgent82 {
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String[]]$ComputerName
    )
$classKey="IdentifyingNumber=`"`{65CD7423-58EA-4DCE-99ED-4870B82AF70A`}`",Name=`"Radia Client Automation Application Manager Agent`",version=`"8.10.0000`""
#[wmi]"\root\cimv2:Win32_Product.$classkey" 
foreach($ComputerName in $ComputerNames)
    { 
    ([wmi]"\\$ComputerName\root\cimv2:Win32_Product.$classKey").uninstall() 
    }
}