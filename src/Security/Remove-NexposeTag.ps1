

Function Remove-NexposeTag{
<#
    .SYNOPSIS
        Returns detailed asset info
    .DESCRIPTION
        Returns detailed asset info
            
    .PARAMETER AssetID
        Asset ID number
    
    .EXAMPLE
      Get-AssetDetails -AssetID '123'

#>
Param(
[String]
[Parameter(Mandatory=$True)]
$TagID,

[String]
[Parameter(Mandatory=$True)]
[ValidateSet("asset", "site", "asset_group")]
$RemoveFrom,

[String]
[Parameter(Mandatory=$True)]
$ID
)
$cookie = New-Object System.Net.Cookie
$cookie.Name = 'nexposeCCSessionID'
$cookie.Value = "$SCRIPT:session_id"
$cookie.Domain = "$server"

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.Cookies.Add($cookie)

switch($RemoveFrom){
    asset {$directory = "/api/2.1/assets/$ID/tags/$TagID"}
    site {$directory = "/api/2.0/sites/$ID/tags/$TagID"}
    asset_groups {$directory = "/api/2.0/asset_groups/$ID/tags/$TagID"}
    
}

$resp = Invoke-WebRequest https://$SCRIPT:server$directory -Method Delete -WebSession $session | ConvertFrom-Json
$resp

}

