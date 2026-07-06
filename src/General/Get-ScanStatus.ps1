# Purpose: Get-ScanStatus — General-purpose PowerShell utilities.

Function Get-ScanStatus{

param([string]$ScanID)
Confirm-Session
# Gets data on a specific scan currently running
$sites_request = "<ScanStatusRequest session-id='$SCRIPT:session_id' scan-id='$ScanID'/>"
$resp = Invoke-WebRequest -URI $uri -Body $sites_request -ContentType 'text/xml' -Method post
[xml]$xmldata = $resp.content
if($xmldata.ScanStatusResponse.success -like '0'){
    Write-host 'ERROR: '$xmldata.ScanStatusResponse.Failure.message -ForegroundColor Red
    }
    Else{
    $xmldata.ScanStatusResponse.Scan
    }
}
