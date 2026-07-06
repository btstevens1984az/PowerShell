# Purpose: FileDialog — File and folder management utilities.
#using assembly "System.windows.forms"
Function GetFileName
{ 
param($initialDirectory = "c:\")

#add-type  -AssemblyName "System.windows.forms"
 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = "All files (*.*)| *.*"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} #end function Get-FileName

GetFileName

