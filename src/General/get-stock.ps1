# Purpose: get-stock — General-purpose PowerShell utilities.
# get a stock quote by name
# 

$webclient=New-Object System.Net.WebClient            
$webclient.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials


$url = "http://www.webserviceex.net/stockquote.asmx?wsdl"
$proxy = New-WebServiceProxy $url
([xml]$proxy.GetQoute("MSFT")).StockQuotes.StockQuotes

