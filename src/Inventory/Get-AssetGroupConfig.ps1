Function Get-AssetGroupConfig{
<#
    .SYNOPSIS
        Retrieves asset group summaries out of Nexpose by asset group ID.
    .DESCRIPTION
        Retrieves asset group summaries out of Nexpose by asset group ID. The summary contains asset group id, name and riskscore. Devices in the asset group can also be retrieved.
    .PARAMETER assetgroupid
        Asset group ID to lookup
    
    .EXAMPLE
        
        Get-AssetGroupConfig 1788

        returns list of device for the site:
        (Get-AssetGroupConfig 1788).Devices.device

#>
param([String]$assetgroupid)
# Request by ID
Confirm-Session
$sites_request = "<AssetGroupConfigRequest session-id='$SCRIPT:session_id' group-id= '$assetgroupid'/>"

$resp = Invoke-WebRequest -URI $uri -Body $sites_request -ContentType 'text/xml' -Method post -DisableKeepAlive
[xml]$xmldata = $resp.content
if($xmldata.AssetGroupConfigResponse.success -eq '0'){
    Write-Host 'ERROR: '$xmldata.AssetGroupConfigResponse.Failure.message -ForegroundColor Red
    }
    Else{
    $xmldata.AssetGroupConfigResponse.AssetGroup
    }
}