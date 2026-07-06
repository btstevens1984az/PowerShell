Function Get-SiteConfig{
<#
    .SYNOPSIS
        Returns site information by site ID.
    .DESCRIPTION
        Returns site information by site ID. Contains site id, name, description, riskfactor, isdynamic, hosts, credentials, alerting, scanConfig
    .PARAMETER SiteID
        Just the site ID
    
    .EXAMPLE
        
        Get-SiteConfig 285

        Gets Scan configuration:
        (Get-SiteConfig 285).scanconfig

#>
Param([string]$SiteID)
Confirm-Session
# Get sites configurations
$sites_request = "<SiteConfigRequest session-id='$SCRIPT:session_id' site-id='$SiteID'/>"
$resp = Invoke-WebRequest -URI $uri -Body $sites_request -ContentType 'text/xml' -Method post
[xml]$xmldata = $resp.content
if($xmldata.SiteConfigResponse.success -eq '0'){
    Write-Host 'ERROR: '$xmldata.SiteConfigResponse.Failure.message -ForegroundColor Red
    }
    Else{
    $xmldata.SiteConfigResponse.Site
    }
}