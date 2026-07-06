# Purpose: ExpandCab — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 1/3/2009
#
# KEYWORDS: Shell.Application object, com object,
# expand cab, throw, function, param
# COMMENTS: This script uses the Shell.Application 
# object and the copyhere method to expand the files from
# the filesystem object
#
#
# ------------------------------------------------------------------------
Param(
      $cab = "C:\fso\acab.cab",
      $destination = "C:\fso1",
      [switch]$debug
     )
Function ConvertFrom-Cab($cab,$destination)
{
 $comObject = "Shell.Application"
 Write-Debug "Creating $comObject"
 $shell = New-Object -Comobject $comObject
 if(!$?) { $(Throw "unable to create $comObject object")}
 Write-Debug "Creating source cab object for $cab"
 $sourceCab = $shell.Namespace($cab).items()
 Write-Debug "Creating destination folder object for $destination"
 $DestinationFolder = $shell.Namespace($destination)
 Write-Debug "Expanding $cab to $destination"
 $DestinationFolder.CopyHere($sourceCab)
}

# *** entry point ***
if($debug) { $debugPreference = "continue" }
ConvertFrom-Cab -cab $cab -destination $destination