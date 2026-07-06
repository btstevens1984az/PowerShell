# Purpose: Ping-MultipleHosts — Network diagnostics, DNS, DHCP, and connectivity.
Function Ping-MultipleHosts {

param (
 
    [Parameter(Mandatory = $true)]
    $SourceFile,
 
    [Parameter(Mandatory = $true)]
    $OutFile
 
)
 
Function Ping-Hosts {
 
param ($server)
 
$test = Test-Connection $server -Count 1 -Quiet -ErrorAction SilentlyContinue
$ip = Test-Connection $server -Count 1 | select ipv4address -ErrorAction SilentlyContinue
$ip = $ip.IPV4Address
 
if ($test.ToString() -like "true") {
 
    Write-Host "$server,$ip,Pingable" -ForegroundColor green
    Write-Output "$server,$ip,yes" | Out-File $OutFile -Append
 
}
else {
    Write-Host "$server,NotPingable" -ForegroundColor Red
    Write-Output "$server,$ip,no" | Out-File $OutFile -Append
 
}
 
$test = $null
$name = $null
$server = $null
$ip = $null
}
 
$filetype = $SourceFile.split(".")[1]
 
Write-Output "ServerName,IP,RespondsToPING" | Out-File $OutFile -force
 
if ($filetype -eq "txt"){
 
    gc $sourcefile | % {
 
        ping-hosts $_
 
}
}
 
Elseif ($filetype -eq "csv"){
 
    Import-Csv $sourcefile | % {
 
        ping-hosts $_.dnsname
 
}
}
 
else{
 
Write-Host "Filetype: $filetype not recognized. Filetype must be .csv or .txt . Please try again." -ForegroundColor DarkRed -BackgroundColor White
 
    }

}