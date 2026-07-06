

Function Get-NexposeReportListing{
<#
    .SYNOPSIS
        Returns list of all reports or a report can be specified by name, ID, status and time generated.
    .DESCRIPTION
       Returns list of all reports or a report can be specified by name, ID, status and time generated. This module allows the use of wildcards to return multiple matches.

    .PARAMETER Name
        Can be used to search for a report by report name. used like this '*reportname*'

    .PARAMETER TemplateID
        Can be used to search for a report by the TemplateID used. used like this 'TemplateID'

    .PARAMETER Status
        Can be used to search for a report by the status of the report. Only accepts these values: Started, Generated, Failed, Aborted, Unknown, *
    
    
    .EXAMPLE
        Get-NexposeReportListing -Name reportnam*
#>
Param(
    [String]
    $Name = '*',
    
    [String]
    $TemplateID = '*',

    [ValidateSet("Started", "Generated", "Failed", "Aborted", "Unknown", "*")]
    [String]
    $Status = '*',

    [String]
    $GeneratedOn = '*'
    )
Confirm-Session
# Gets vulnerability listing
$sites_request = "<ReportListingRequest session-id='$SCRIPT:session_id'/>"
$resp = Invoke-WebRequest -URI $uri -Body $sites_request -ContentType 'text/xml' -Method post
[xml]$xmldata = $resp.content
if($xmldata.ReportListingResponse.success -like '0'){
    Write-host 'ERROR: '$xmldata.ReportListingResponse.Failure.message -ForegroundColor Red
    }
    Else{
       
    $xmldata.ReportListingResponse.ReportConfigSummary | where { $_.name -like "$Name" -and $_.status -like "$Status" -and $_.'template-id' -like "$TemplateID" -and $_.'generated-on' -like "$GeneratedOn" } 
    
    }
}
