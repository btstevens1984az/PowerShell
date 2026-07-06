
Function Get-TagDetails{
<#
    .SYNOPSIS
        Returns detailed info on tags
    .DESCRIPTION
        Returns detailed info on tags
            
    .PARAMETER tagID
        ID# of the tag.
    
    .EXAMPLE
      Get-TagDetails -tag_ID '123'

#>
Param([String]
[Parameter(Mandatory=$true, ValueFromPipeline=$true)]

$tag_id)
$cookie = New-Object System.Net.Cookie
$cookie.Name = 'nexposeCCSessionID'
$cookie.Value = "$SCRIPT:session_id"
$cookie.Domain = "$server"

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.Cookies.Add($cookie)
#$directory = '/api/2.0/tags'
#$resp = Invoke-WebRequest https://$SCRIPT:server$directory -WebSession $session | ConvertFrom-Json
# first request only pulls one page of tags. this code will make all tags fit on one page.
#$tagNumber = $resp.total_available
#$directory = "https://$SCRIPT:server/api/2.0/tags?per_page=$tagNumber"
#$resp = Invoke-WebRequest $directory -WebSession $session | ConvertFrom-Json
#$taglist += $resp.resources

#$TagID = ($taglist | where { $_.tag_name -like "$TagName" }).tag_id
$directory = "https://$SCRIPT:server/api/2.0/tags/$tag_id"
$resp = Invoke-WebRequest $directory -WebSession $session | ConvertFrom-Json
$resp

}