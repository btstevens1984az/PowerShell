# Purpose: Resolve-WhoIs — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE:1/31/2009
#
# KEYWORDS: New-WebServiceProxy, WSDL, URI
#
# COMMENTS: This script uses the New-WebServiceProxy
# cmdlet to resolve a whois query
#
# Windows PowerShell Best Practices
# ------------------------------------------------------------------------
#Requires -Version 2.0
Function Resolve-WhoIs($WhoIs)
{
 $URI = "http://www.webservicex.net/whois.asmx?WSDL"
 $WhoIsProxy = New-WebServiceProxy -uri $URI -namespace WebServiceProxy -class WhoIs
 $WhoIsProxy.getWhoIs($WhoIs)
} #end Resolve-WhoIs

Resolve-WhoIs -whois edwilson.com