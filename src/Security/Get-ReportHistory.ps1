Function Get-ReportHistory{
<#
    .SYNOPSIS
        Returns the run history of a report. 
    .DESCRIPTION
        Returns the run history of a report.  

    .PARAMETER ReportID
        This should be any cfg-id. the cfg-id can be gotten while runing the Get-ReportListing function.
    
    
    .EXAMPLE
        Get-ReportHistory 3916

#>
Param([Parameter(Mandatory=$True)][String]$ReportID)
Confirm-Session
# Gets vulnerability listing
$sites_request = "<ReportHistoryRequest session-id='$SCRIPT:session_id' reportcfg-id='$ReportID' />"
$resp = Invoke-WebRequest -URI $uri -Body $sites_request -ContentType 'text/xml' -Method post
[xml]$xmldata = $resp.content
if($xmldata.ReportHistoryResponse.success -like '0'){
    Write-host 'ERROR: '$xmldata.ReportHistoryResponse.Failure.message -ForegroundColor Red
    }
    Else{
    $xmldata.ReportHistoryResponse.ReportSummary
    }
}