# Purpose: Get-HTTPstatus — General-purpose PowerShell utilities.
# http monitor process

# send a http request
 $req = [system.Net.WebRequest]::Create('http://itweb')
 
# see what the result is
  $res = $req.GetResponse()
  
 # check the Status code
 $res.StatusCode
 
 # get an Integer number for the code
 [int]$res.StatusCode
 