Function Remove-NexposeAsset{
<#
    .SYNOPSIS
        Deletes an asset by asset ID.
    .DESCRIPTION
        Deletes an asset by asset ID.
            
    .PARAMETER AssetID
        Asset ID number
    
    .EXAMPLE
      Delete-NexposeAsset 132

#>
Param([String] $AssetID)
Confirm-Session
$sites_request = "<DeviceDeleteRequest session-id='$SCRIPT:session_id' device-id= '$AssetID'/>"

$resp = Invoke-WebRequest -URI $uri -Body $sites_request -ContentType 'text/xml' -Method post -DisableKeepAlive
[xml]$xmldata = $resp.content
if($xmldata.DeviceDeleteResponse.success -eq '0'){
    Write-Host 'ERROR: '$xmldata.DeviceDeleteResponse -ForegroundColor Red
    }
    Else{
    $xmldata.DeviceDeleteResponse
    }

}