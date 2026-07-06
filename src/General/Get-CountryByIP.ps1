# Purpose: Get-CountryByIP — General-purpose PowerShell utilities.
﻿<#
   .Synopsis
    Gets country location by IP address
   .Description
    This script gets country location based up an IP address. It uses
    a web service, and therefore must be connected to internet.
   .Example
    Get-CountryByIP.ps1 -ip 56.194.250.50, 203.135.6.89 -log iplog.txt
    Writes country information to %mydocuments%\iplog.txt and to screen
   .Inputs
    [string]
   .OutPuts
    [PSObject]
    VERSION: 1.0.0
    KEYWORDS: New-WebServiceProxy, IP, New-Object, PSObject
   .Link
     Http://www.ScriptingGuys.com
#Requires -Version 2.0
#>
[CmdletBinding()]
Param(
   [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $true)]
   [string[]]$ip, 
   [string]$log = "ipLogFile.txt",
   [string]$folder = "Personal"
)#end param

# *** Function below ***
Function Get-CountryByIP($IP)
{
 $URI = "http://www.webservicex.net/geoipservice.asmx?wsdl"
 $Proxy = New-WebServiceProxy -uri $URI -namespace WebServiceProxy -class IP
 $RTN = $Proxy.GetGeoIP($IP)
 
 $ipReturn = New-Object psobject
 $ipReturn | Add-Member -MemberType noteproperty -Name ip -Value $rtn.ip
 $ipReturn | Add-Member -MemberType noteproperty -Name countryName -Value $rtn.CountryName
 $ipReturn | Add-Member -MemberType noteproperty -Name countryCode -Value $rtn.CountryCode
 $ipReturn
} #end Get-CountryByIP

Function Get-Folder($folderName)
{
 [Environment]::GetFolderPath([environment+SpecialFolder]::$folderName)
} #end function Get-Folder

# *** Entry Point to Script ***

$ip | 
ForEach { Get-CountryByIP -ip $_ } |
Tee-Object -Variable results

$results | 
Out-File -FilePath `
  (Join-Path -Path (Get-Folder -folderName $folder) -childPath $log) 