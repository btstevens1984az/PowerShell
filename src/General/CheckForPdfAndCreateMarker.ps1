# Purpose: CheckForPdfAndCreateMarker — General-purpose PowerShell utilities.
# -----------------------------------------------------------------------------------
# CheckForPdfAndCreateMarker.ps1
# ed wilson, msft, 12/11/2008
# 
# Hey Scripting Guy! 12/29/2008
# -----------------------------------------------------------------------------------
$path = "c:\fso"
$include = "*.pdf"
$name = "nopdf.txt"
if(!(Get-ChildItem -path $path -include $include -Recurse)) 
  { 
    "No pdf was found in $path. Creating $path\$name marker file."
    New-Item -path $path -name $name -itemtype file -force |
    out-null
  } #end if not Get-Childitem
ELSE
 {
  $response = Read-Host -prompt "PDF files were found. Do you wish to delete <y> /<n>?"
  if($response -eq "y")
    {
     "Pdf files will be deleted."
     Get-ChildItem -path $path -include $include -recurse |
      Remove-Item
    } #end if response
  ELSE
   { 
    "PDF files will not be deleted."
   } #end else reponse
 } #end else not Get-Childitem
