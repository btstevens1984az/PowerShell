Function Get-ScanActivity{
<#
    .SYNOPSIS
        Returns list of Active scans.
    .DESCRIPTION
        Returns list of Active scans.

    .EXAMPLE
        
        Get-ScanActivity

#>
Confirm-Session
# Get list of Current Scans
$sites_request = "<ScanActivityRequest session-id='$SCRIPT:session_id'/>"
$resp = Invoke-WebRequest -URI $uri -Body $sites_request -ContentType 'text/xml' -Method post
[xml]$xmldata = $resp.content
if($xmldata.ScanActivityResponse.success -like '0'){
    Write-host 'ERROR: '$xmldata.ScanActivityResponse.Failure.message -ForegroundColor Red
    }
    Else{
    $xmldata.ScanActivityResponse.ScanSummary
    }
}