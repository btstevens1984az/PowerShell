# Purpose: ConvertTo-LatLngCoords — General-purpose PowerShell utilities.
Function ConvertTo-LatLngCoords {
  <#
  .Synopsis
     This script takes city name/s and returns the Long and Lat Coordinates
  .DESCRIPTION
     This script utilises one of the APIs that have been created by Google
     to convert city names into coordinates. It produces a custom object
     output that contains the city name, Longatude and Latitude.
     If there is more than one city in the database the script will show 
     all known cities and their details.
  
     Coordinate Accuracy
     places   degrees          distance
     -------  -------          --------
     0        1                111  km
     1        0.1              11.1 km
     2        0.01             1.11 km
     3        0.001            111  m
     4        0.0001           11.1 m
     5        0.00001          1.11 m
     6        0.000001         11.1 cm
     7        0.0000001        1.11 cm
     8        0.00000001       1.11 mm
  .EXAMPLE
     ConvertTo-LatLngCoords -City Chicago
  .EXAMPLE
     ConvertTo-LatLngCoords -City Chicago,Sydney
  .PARAMETER city
     Choose any major or semi-major city in the world to be converted into 
     Coordicates
     Creation: Brandon Stevens 11/Oct/2017
   .ROLE
     The role this cmdlet is to show how APIs work and how PowerShell
     can use them
  #>
  [CmdletBinding()]
  Param(
    [parameter(Mandatory=$true)]
    [string[]]$City
  )
  
  foreach ($CityName in $City) {  # Use  Google API to get GEOCODE
    $resultAPI = Invoke-RestMethod -Method Get -Uri "https://maps.googleapis.com/maps/api/geocode/json?address=${CityName}&sensor=false" -UseBasicParsing
    $locations = $resultAPI.results
    foreach ($location in $locations) {  # Just in case there are multiple cities with same name
      $Coords = $location.geometry.location
      $outputProp = [ordered]@{
        Lat = ('{0:N6}' -f $Coords.lat) -as [double]
        Lng = ('{0:N6}' -f $Coords.lng) -as [double]
        City = $location.formatted_address
      } # END Hashtable
      New-Object -TypeName psobject -Property $outputProp
    } #END Foreach
  } #END Foreach
} #END Function
