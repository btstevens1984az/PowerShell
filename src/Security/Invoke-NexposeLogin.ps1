###########################################################
#
# Overview:         Script to interact with NExpose API v3
# Date Created:     02/24/2018
# Function Name:    Invoke-NexposeLogin
# 
###########################################################

function Invoke-NexposeLogin{
<#
    .SYNOPSIS
        This script retrieves a session-ID from nexpose.
    .DESCRIPTION
        This script retrieves a session-ID from nexpose. It will ask for a username and password to pass to the Nexpose API. API version and server name can be changed using parameters.
    .PARAMETER server
        The Nexpose server to communicate with. this can be either IP or hostname.
        **rapid7.example.com:3780**
        **62.177.196.53:3780**
    .PARAMETER api_version
        Allows the user to chooses what API version to use. Default Version: 3
    .EXAMPLE
        Invoke-NexposeLogin
#>
Param (
    [String] 
    [Parameter(Mandatory=$false)]
    $server,
    [String]
    $api_version = '3'
)
$credential = Get-Credential

#Nexpose Instance
$user = $credential.UserName
$pwd = $credential.getnetworkcredential().password
$SCRIPT:uri = "https://rapid7.example.com:3780/api/${api_version}/xml"

#login request string
$login_request = "<LoginRequest synch-id='0' password ='$pwd' user-id = '$user' ></LoginRequest>"


# login and get the session id
$resp = Invoke-WebRequest -URI $uri -Body $login_request -ContentType 'text/xml' -Method post
[xml]$xmldata = $resp.content
if($xmldata.LoginResponse.success -eq '0'){
    Write-Host 'ERROR: '$xmldata.LoginResponse.Failure.message -ForegroundColor Red
    }
    Else{
    $SCRIPT:session_id = $xmldata.LoginResponse.'session-id'
    Write-Host "Login Successful" -ForegroundColor Green
    }
}