# Purpose: CreateCab — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 1/3/2009
#
# KEYWORDS: makecab object, cab file, write-debug
# throw, $? last error, makecab.makecab, function
# COMMENTS: This script creates a cab file from an
# array of files obtained via the get-childitem cmdlet
#
# ------------------------------------------------------------------------
Param(
      $filepath = "C:\fso", 
      $path = "C:\fso\aCab.cab",
      [switch]$debug
     )
Function New-Cab($path,$files)
{
 $makecab = "makecab.makecab"
 Write-Debug "Creating Cab path is: $path"
 $cab = New-Object -ComObject $makecab
 if(!$?) { $(Throw "unable to create $makecab object")}
 $cab.CreateCab($path,$false,$false,$false)
 Foreach ($file in $files)
  {
   $file = $file.fullname.tostring()
   $fileName = Split-Path -path $file -leaf
   Write-Debug "Adding from $file"
   Write-Debug "File name is $fileName"
   $cab.AddFile($file,$filename)
  }
 Write-Debug "Closing cab $path"
 $cab.CloseCab()
} #end New-Cab

# *** entry point to script ***
if($debug) {$DebugPreference = "continue"}
$files = Get-ChildItem -path $filePath | Where-Object { !$_.psiscontainer }
New-Cab -path $path -files $files