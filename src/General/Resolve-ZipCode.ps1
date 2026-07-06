# Purpose: Resolve-ZipCode — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 1/28/2009
#
# KEYWORDS: New-WebServiceProxy, WSDL, URI
#
# COMMENTS: This script uses the New-WebServiceProxy
# cmdlet to resolve a US zipcode into city, state, area code, 
# and timezone. 
#
# Windows PowerShell Best Practices
# ------------------------------------------------------------------------
#Requires -Version 2.0
Function Resolve-ZipCode([int]$zip)
{
 $URI = "http://www.webservicex.net/uszip.asmx?WSDL"
 $zipProxy = New-WebServiceProxy -uri $URI -namespace WebServiceProxy -class ZipClass
 $zipProxy.getinfobyzip($zip).table
} #end Get-ZipCode

Resolve-ZipCode 29745