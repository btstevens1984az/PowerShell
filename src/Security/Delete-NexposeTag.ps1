

Function Delete-NexposeTag{
<#
    .SYNOPSIS
        Deletes a Nexpose tag.
    .DESCRIPTION
        Deletes a Nexpose tag.
            
    .PARAMETER tagID
        ID of the tag.
    
    .EXAMPLE
      Delete-NexposeTag -tagID '123'

#>
Param([Parameter(Mandatory=$true, ValueFromPipeline=$true)] [String] $tagID)
$cookie = New-Object System.Net.Cookie
$cookie.Name = 'nexposeCCSessionID'
$cookie.Value = "$SCRIPT:session_id"
$cookie.Domain = "$server"

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.Cookies.Add($cookie)

$headers = @{}
$headers.Add("Accept","*/*")
$headers.Add("nexposeCCSessionID","$SCRIPT:session_id")
$headers.Add("X-Requested-With","XMLHttpRequest")
$headers.Add("Content-Type","application/json; charset=utf-8")

$directory = "https://$SCRIPT:server/data/tag?tagIDs=$tagID"
$resp = Invoke-WebRequest $directory -Headers $headers -Method Delete -WebSession $session
$resp
}