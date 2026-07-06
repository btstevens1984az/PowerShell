Function Get-ScanStatistics{
<#
    .SYNOPSIS
        Returns scan information given a scan ID.
    .DESCRIPTION
        Returns scan information given a scan ID. Can also use scan ID of a scan that completed. Information includes scan-id, site-id, name, startTime, endTime, status, tasks, nodes and vulnerabilities
    .PARAMETER ScanID
        Just the scan ID

    .PARAMETER EngineID
        Engine ID for scan. This is not need.
    
    .EXAMPLE
        
        Get-ScanStatistics 77540

#>
param([string]$ScanID, [String]$EngineID)
Confirm-Session
# Gets statistics on any scan ID
$sites_request = "<ScanStatisticsRequest session-id='$SCRIPT:session_id' engine-id ='$EngineID' scan-id='$ScanID'/>"
$resp = Invoke-WebRequest -URI $uri -Body $sites_request -ContentType 'text/xml' -Method post
[xml]$xmldata = $resp.content
if($xmldata.ScanStatisticsResponse.success -like '0'){
    Write-host 'ERROR: '$xmldata.ScanStatisticsResponse.Failure.message -ForegroundColor Red
    }
    Else{
    $xmldata.ScanStatisticsResponse.ScanSummary
    }
}