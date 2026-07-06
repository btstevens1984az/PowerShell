Function Get-SiteListing{
<#
    .SYNOPSIS
        Gets a list of sites.
    .DESCRIPTION
        Gets a list of sites including id, name, description, riskfactor and riskscore.
    
    .EXAMPLE
        
        Get-SiteListing

#>
Confirm-Session
# Get list of sites
$sites_request = "<SiteListingRequest session-id='$SCRIPT:session_id'/>"
$resp = Invoke-WebRequest -URI $uri -Body $sites_request -ContentType 'text/xml' -Method post
[xml]$xmldata = $resp.content
if($xmldata.SiteListingResponse.success -eq '0'){
    Write-Host 'ERROR: '$xmldata.SiteListingResponse.Failure.message -ForegroundColor Red
    }
    Else{
    $xmldata.SiteListingResponse.SiteSummary
    }
}