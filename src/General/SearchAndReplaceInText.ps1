# Purpose: SearchAndReplaceInText — General-purpose PowerShell utilities.
﻿# -----------------------------------------------------------------------------
#
# SearchAndReplaceInText.ps1
# ed wilson, msft, 11/1/2008
#
# Uses Get-Childitem to obtain collection of files specified by the $filetypes
# variable. Uses the $path variable to specify the path to search. Keep in mind
# the * is required at the end of the \
# We use foreach-object to walk through the collection of files.
# we use [io.path] to create the temp file
# the -replace operator is available through out places and replaces the
# pattern match in the stream of content that is produced by get-content
# We write this to the temp file by using add-content
# then we delete the old file, and move the new file.
#
# -----------------------------------------------------------------------------
$path = "c:\bp\*"
$oldValue = "dc=msft"
$newValue  = "dc=com"
$fileTypes = "*.ps1","*.txt"
Get-ChildItem -Path $path -Include $fileTypes|
ForEach-Object `
{
 $tmpFile = [system.io.path]::GetTempFileName()
 Get-Content -Path $_.fullname |
   ForEach-Object `
    {
      $_ -replace $oldValue, $newValue |
      Add-Content $tmpFile
    }
 Remove-Item -Path $_.fullname
 Move-Item -Path $tmpFile -Destination $_.fullName
}
