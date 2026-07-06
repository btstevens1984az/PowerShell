# Purpose: GetStock — General-purpose PowerShell utilities.
Function Get-StockQuotes
{
param ([parameter(Mandatory=$true,ValueFromPipeline=$True,Position = 0,HelpMessage="An array of stock symbols.")] 
	[String] $stock = "msft")
	begin
	{
	$URI = "http://www.webservicex.net/stockquote.asmx?WSDL"
	$stockService = New-WebServiceProxy -Uri $URI -namespace WebServiceProxy
	}
	process
	{
		$quote = $null
		[xml]$quote = $stockService.GetQuote($stock)
		$quote.StockQuotes.Stock
	}
}

$stocks = "msft","cop","afl","AGNC" #"INDU"  # "^GSPC"
$quotes = $stocks | Get-StockQuotes
$quotes | Out-GridView