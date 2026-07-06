
Function Get-EngineListing{
<#
    .SYNOPSIS
        Returns a list of Nexpose engines
    .DESCRIPTION
        Returns a list of Nexpose engines
    
    .EXAMPLE
        
        Get-EngineListing

#>
Confirm-Session
# Gets data on a specific scan currently running
$sites_request = "<EngineListingRequest session-id='$SCRIPT:session_id'/>"
$resp = Invoke-WebRequest -URI $uri -Body $sites_request -ContentType 'text/xml' -Method post
[xml]$xmldata = $resp.content
if($xmldata.EngineListingResponse.success -like '0'){
    Write-host 'ERROR: '$xmldata.EngineListingResponse.Failure.message -ForegroundColor Red
    }
    Else{
    $xmldata.EngineListingResponse.EngineSummary
    }
}