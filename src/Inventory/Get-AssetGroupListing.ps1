# Purpose: Get-AssetGroupListing — Hardware and software inventory collection.
Function Get-AssetGroupListing{
Confirm-Session
# Get list of asset groups
$sites_request = "<AssetGroupListingRequest session-id='$SCRIPT:session_id'/>"
$resp = Invoke-WebRequest -URI $uri -Body $sites_request -ContentType 'text/xml' -Method post
[xml]$xmldata = $resp.content
if($xmldata.AssetGroupListingResponse.success -eq '0'){
    Write-Host 'ERROR: '$xmldata.AssetGroupListingResponse.Failure.message -ForegroundColor Red
    }
    Else{
    $xmldata.AssetGroupListingResponse.AssetGroupSummary
    }
}