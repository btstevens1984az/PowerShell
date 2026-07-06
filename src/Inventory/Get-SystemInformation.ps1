Function Get-SystemInformation{
<#
    .SYNOPSIS
        Returns System information. need to be an admin
    .DESCRIPTION
        Returns System information. need to be an admin
    
    .EXAMPLE
        
        Get-SystemInformation

#>
Confirm-Session
# Gets data on a specific scan currently running
$sites_request = "<SystemInformationRequest session-id='$SCRIPT:session_id'/>"
$resp = Invoke-WebRequest -URI $uri -Body $sites_request -ContentType 'text/xml' -Method post
[xml]$xmldata = $resp.content
if($xmldata.SystemInforamtionResponse.success -like '0'){
    Write-host 'ERROR: '$xmldata.SystemInforamtionResponse.Failure.message -ForegroundColor Red
    }
    Else{
    $xmldata.SystemInformationResponse.StatisticsInformationSummary.Statistic
    
    }
}
