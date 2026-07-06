# Purpose: Get-NexposePage — Security auditing and compliance checks.

Function Get-NexposePage{
Param([string] $URI)
$cookie = New-Object System.Net.Cookie
$cookie.Name = 'nexposeCCSessionID'
$cookie.Value = "$SCRIPT:session_id"
$cookie.Domain = "$server"

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.Cookies.Add($cookie)
$headers = @{}
$headers.Add("Accept","text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
$headers.Add("X-Requested-With","XMLHttpRequest")
$headers.Add("nexposeCCSessionID","$SCRIPT:session_id")
$headers.Add("Content-Type","application/x-www-form-urlencoded; charset=UTF-8")
    Invoke-WebRequest $URI -WebSession $session

}
