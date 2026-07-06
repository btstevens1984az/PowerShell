# Purpose: Search-Bing — General-purpose PowerShell utilities.
function New-MyString
{
    $args -join " "
}


Function Search-Bing
{
    param(
          [parameter(
          ValueFromPipelineByPropertyName=$true,
          ValueFromPipeLine=$true,
          Mandatory=$true,
          Position=0)]
    [string]$query)

    PROCESS
    {
        Start-Process "http://www.bing.com/search?q=$query"
    }
}

New-Alias -Name Bing -Value Search-Bing
New-Alias -Name q -Value New-MyString