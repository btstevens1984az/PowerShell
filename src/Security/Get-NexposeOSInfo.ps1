# Purpose: Get-NexposeOSInfo — Security auditing and compliance checks.
# Pull generic OS Numbers
Function Get-NexposeOSInfo{

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
[xml]$resp = (Invoke-WebRequest https://$SCRIPT:server/data/asset/os/dyntable?printDocType=0%26tableID=OSSynopsisTable -WebSession $session).content
$OS = @();
foreach($line in $resp.DynTable.Data.tr){$val = New-Object psobject;
    $val | Add-Member -MemberType NoteProperty -Name OSID -Value $line.td[0]
    $val | Add-Member -MemberType NoteProperty -Name OSName -Value $line.td[2]
    $val | Add-Member -MemberType NoteProperty -Name Product -Value $line.td[3]
    $val | Add-Member -MemberType NoteProperty -Name Vendor -Value $line.td[4]
    $val | Add-Member -MemberType NoteProperty -Name Architecture -Value $line.td[5]
    #convert instances to int instead of string so we can sort on it
    $instance = [int]$line.td[6]
    $val | Add-Member -MemberType NoteProperty -Name Instances -Value $instance
    $OS += $val    
    }
$OS
}
