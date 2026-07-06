###########################################################
#
# Overview:         Script to interact with NExpose API v3
# Date Created:     02/24/2018
# File Name:        Invoke NexposeLogout
# 
###########################################################

Function Invoke-NexposeLogout{
<#
    .SYNOPSIS
        Ends session with Nexpose.
    .DESCRIPTION
        Ends session with Nexpose.
    .EXAMPLE
        Invoke-NexposeLogout
#>
$logout_request = "<LogoutRequest synch-id='0' session-id ='$SCRIPT:session_id' ></LogoutRequest>"
$resp = Invoke-WebRequest -URI $uri -Body $logout_request -ContentType 'text/xml' -Method post
$resp
}