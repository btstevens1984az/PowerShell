<#
    .SYNOPSIS
 
    Connects to a given URI and returns status about it: URI, response code,
    and time taken.
 
    .EXAMPLE
 
    PS > Test-Uri bing.com
 
    Uri : bing.com
    StatusCode : 200
    StatusDescription : OK
    ResponseLength : 34001
    TimeTaken : 459.0009
 
#>
Function Test-Uri{
  param(
    ## The URI to test
    $Uri
  )

  $request = $null
  $time = try
  {
    ## Request the URI, and measure how long the response took.
    $result = Measure-Command { $request = Invoke-WebRequest -Uri $uri }
    $result.TotalMilliseconds
  }
  catch
  {
    ## If the request generated an exception (i.e.: 500 server
    ## error or 404 not found), we can pull the status code from the
    ## Exception.Response property
    $request = $_.Exception.Response
    $time = -1
  }

  $result = [PSCustomObject] @{
    Time = Get-Date;
    Uri = $uri;
    StatusCode = [int] $request.StatusCode;
    StatusDescription = $request.StatusDescription;
    ResponseLength = $request.RawContentLength;
    TimeTaken = $time;
  }

  $result
  }