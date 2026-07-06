# Purpose: Rename-FileExtension — Storage management and disk operations.
# ------------------------------------------------------------------------
# DATE: 1/28/2009
#
# KEYWORDS: function, Get-ChildItem, Rename-Item,
# ForEach-Object
# COMMENTS: This function changes the file extension
# for all the files in a particular folder. The function takes
# three parameters: the path, oldExtension and newExtension
# it uses pipelining to do this. psh 2.0 is required due to the script property
# basename which is added to the file object
#
# Windows PowerShell Best Practices
# ------------------------------------------------------------------------
#Requires -Version 2.0
Function Rename-FileExtension($path,$oldExtension, $newExtension)
{
 Get-ChildItem -path $path -Filter $oldExtension | 
 Foreach-Object { 
 Rename-Item -Path $_.fullname -newname ($_.basename + $newExtension) 
 }
} #end function

Rename-FileExtension -path "C:\fso" -oldExtension "*.txt1" -newExtension ".txt"
