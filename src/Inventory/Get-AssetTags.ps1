
Function Get-AssetTags{
<#
    .SYNOPSIS
        Pull a list of all tags or specify a name.
    .DESCRIPTION
        Pull a list of all tags or specify a name.
            
    .PARAMETER Name
        Name of the tag.
    
    .EXAMPLE
      Get-TagListing -TagName 'tagname*'

#>
Param([String] [parameter(ValueFromPipeline=$true)] $AssetID)
$cookie = New-Object System.Net.Cookie
$cookie.Name = 'nexposeCCSessionID'
$cookie.Value = "$SCRIPT:session_id"
$cookie.Domain = "$server"

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.Cookies.Add($cookie)
$directory = "https://$SCRIPT:server/api/2.0/tags?per_page=$tagNumber"
$resp = Invoke-WebRequest $directory -WebSession $session | ConvertFrom-Json
$taglist += $resp.resources

$taglist | where { $_.tag_name -like "$tag_name" }

}