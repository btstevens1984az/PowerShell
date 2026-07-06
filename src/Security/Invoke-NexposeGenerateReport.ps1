
Function Invoke-NexposeGenerateReport{
<#
    .SYNOPSIS
        Generates a report by ID 
    .DESCRIPTION
        Generates a report by ID  
   
    .EXAMPLE
        Invoke-NexposeGenerateReport -reportID 123

#>
Param([Parameter(Mandatory=$True)][String] $reportID)
Confirm-Session
# Gets vulnerability listing
$sites_request = "<ReportGenerateRequest session-id='$SCRIPT:session_id' report-id='$reportID'/>"
$resp = Invoke-WebRequest -URI $uri -Body $sites_request -ContentType 'text/xml' -Method post
[xml]$xmldata = $resp.content
if($xmldata.ReportGenerateRequest.success -like '0'){
    Write-host 'ERROR: '$xmldata.ReportGenerateRequest.Failure.message -ForegroundColor Red
    }
    Else{
    $xmldata.ReportGenerateRequest.ReportSummary
    }
}
