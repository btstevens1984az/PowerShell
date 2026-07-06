# Purpose: Get-InternetProxy — Reusable PowerShell function libraries.
function Get-InternetProxyAutoConfigURL
 { 
     param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String[]]$ComputerName
    )
    <# 
            .SYNOPSIS 
                Determine the internet proxy address
            .DESCRIPTION
                This function allows you to determine the the internet proxy address used by your computer
            .EXAMPLE 
                Get-InternetProxyAutoConfigURL
                WebSite: http://obilan.be 
    #> 

$regKey="HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
$proxyURL = "http://proxy.example.com/proxy.pac"
Write-Host "Retrieve the proxy script settings"
$ProxySettingsAutoConfigURL = Get-ItemProperty -path $regKey.AutoConfigURL -ErrorAction SilentlyContinue
Write-Host $ProxySettingsAutoConfigURL
if([string]::IsNullOrEmpty($proxyURL))
{
    Write-Host "Proxy script has been added"
}
else
{
    Write-Host "Proxy is enabled"
    Get-ItemProperty -path $regKey.AutoConfigURL
    Write-Host "Proxy Script was previously enabled"
    }
    }