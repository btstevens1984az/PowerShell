Function Get-AssetDetails{
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
$AssetID,

[String]
[ValidateSet("", "tags", "scans", "vulnerabilities", "software", "files", "services", "unique_identifiers", "vulnerability_instances", "users", "user_groups")]
$InfoType = ""
)
$cookie = New-Object System.Net.Cookie
$cookie.Name = 'nexposeCCSessionID'
$cookie.Value = "$SCRIPT:session_id"
$cookie.Domain = "$server"

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.Cookies.Add($cookie)

switch($InfoType){
    tags {$directory = "/api/2.1/assets/$AssetID/tags"}
    scans {$directory = "/api/2.1/assets/$AssetID/scans"}
    vulnerabilities {$directory = "/api/2.1/assets/$AssetID/vulnerabilities"}
    services {$directory = "/api/2.1/assets/$AssetID/services"}
    unique_identifiers {$directory = "/api/2.1/assets/$AssetID/unique_identifiers"}
    vulnerability_instances {$directory = "/api/2.1/assets/$AssetID/vulnerability_instances"}
    users {$directory = "/api/2.1/assets/$AssetID/users"}
    user_groups {$directory = "/api/2.1/assets/$AssetID/user_groups"}
    default {$directory = "/api/2.1/assets/$AssetID"}

}


$resp = Invoke-WebRequest https://$SCRIPT:server$directory -WebSession $session | ConvertFrom-Json
$resp

}