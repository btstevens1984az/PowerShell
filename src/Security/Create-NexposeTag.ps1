

Function Create-NexposeTag{
<#
    .SYNOPSIS
        Creates a Nexpose tag.
    .DESCRIPTION
        Creates a Nexpose tag.
            
    .PARAMETER Name
        Name of the tag.
    
    .EXAMPLE
      Create-NexposeTag -Name 'test'

#>
Param([String] $Type = 'CUSTOM', [Parameter(Mandatory=$true)] [String] $Name, [String] $Color = '#f6f6f6')
$cookie = New-Object System.Net.Cookie
$cookie.Name = 'nexposeCCSessionID'
$cookie.Value = "$SCRIPT:session_id"
$cookie.Domain = "$server"

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.Cookies.Add($cookie)
$headers = @{}
$headers.Add("Accept","application/json, text/javascript, */*; q=0.01")
$headers.Add("nexposeCCSessionID","$SCRIPT:session_id")
$headers.Add("X-Requested-With","XMLHttpRequest")
$headers.Add("Content-Type","application/json; charset=utf-8")
$postParams = "[{`"type`":`"$Type`",`"name`":`"$Name`",`"color`":`"$Color`",`"tagAttributes`":[{`"name`":`"COLOR`",`"value`":`"$Color`"}]}]"

$directory = "https://$SCRIPT:server/data/tag"
$resp = Invoke-WebRequest $directory -Headers $headers -Method Put -Body $postParams -WebSession $session
$resp
}