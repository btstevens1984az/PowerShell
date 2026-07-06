# Purpose: Get-InitialDirectoryOfFile — Storage management and disk operations.
#using assembly "System.windows.forms"
Function Get-FileName
{ 
param($initialDirectory = "c:\")

#add-type  -AssemblyName "System.windows.forms"
 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = "All files (*.*)| *.*"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} #end function Get-FileName