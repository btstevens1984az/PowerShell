# Purpose: GetWeather — General-purpose PowerShell utilities.

Function Get-Weather
{
param ([parameter(Mandatory=$true,ValueFromPipeline=$True,Position = 0,HelpMessage="An array of zip codes.")] 
	[String] $zip = "33109")
	begin
	{
	$URI = "http://www.webservicex.net/WeatherForecast.asmx?WSDL"
	$weatherService = New-WebServiceProxy -Uri $URI -namespace WebServiceProxy
	}
	process
	{
		$weather = $null
		[xml]$weather = $weatherService.GetWeatherByZipCode($zip)
		$quote.details
	}
}

Function Get-GlobalWeather
{
param ([parameter(Mandatory=$true,ValueFromPipeline=$True,Position = 0,HelpMessage="An array of zip codes.")] 
	[String] $city = "Dallas",[string]$country= "United States")
	begin
	{
	$URI = "http://www.webservicex.net/globalweather.asmx?WSDL"
	$weatherService = New-WebServiceProxy -Uri $URI -namespace WebServiceProxy
	}
	process
	{
		$weather = $null
		[xml]$weather = $weatherService.GetWeather($city,$country)
		$weather.CurrentWeather
		
	}
}