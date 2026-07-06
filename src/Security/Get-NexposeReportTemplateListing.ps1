
Function Get-NexposeReportTemplateListing{
<#
    .SYNOPSIS
        Returns list of all Report Templates. 
    .DESCRIPTION
        Returns list of all Report Templates. 
   
    .EXAMPLE
        Get-NexposeReportTemplateListing

#>
Confirm-Session
# Gets vulnerability listing
$sites_request = "<ReportTemplateListingRequest session-id='$SCRIPT:session_id'/>"
$resp = Invoke-WebRequest -URI $uri -Body $sites_request -ContentType 'text/xml' -Method post
[xml]$xmldata = $resp.content
if($xmldata.ReportTemplateListingResponse.success -like '0'){
    Write-host 'ERROR: '$xmldata.ReportTemplateListingResponse.Failure.message -ForegroundColor Red
    }
    Else{
    $xmldata.ReportTemplateListingResponse.ReportTemplateSummary
    }
}