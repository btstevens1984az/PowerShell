Function Get-CurrentWeather {
<#
.SYNOPSIS
    Just a simple PowerShell script to automate the retrieval your weather via API key.
.DESCRIPTION
    Set your API key from openweathermap.org in $env:OPENWEATHER_API_KEY
.INSTRUCTIONS
    The free api key only permits querying once every 10 minutes...
    Can download city ID codes here: http://bulk.openweathermap.org/sample/
    To convert Kelvin to Fahrenheit:
    TempKelvin * 9/5 - 459.67
    File Name      : Get-CurrentWeather.ps1
    Prerequisite   : PowerShell V2
    Copyright 2018 - Brandon Stevens
.LINK
    http://bulk.openweathermap.org/sample/
.EXAMPLE
     
#>

$GilbertCityID = 5027943
$apiKey = $env:OPENWEATHER_API_KEY
#$uri = "api.openweathermap.org/data/2.5/weather?q=Denver,us&mode=json&APPID=$apiKey"
$uri = "api.openweathermap.org/data/2.5/weather?id=$GilbertCityID&mode=json&APPID=$apiKey"
$results = Invoke-RestMethod $uri
}