Function Get-FilesByExtension {
<# 
.SYNOPSIS 
Shows a list of files for a given file extension. 
.DESCRIPTION 
Function to retrieve files by extension. 
.PARAMETER FolderPath 
The folder path to search. 
.PARAMETER FileExtension 
The file extension to search for. 
.EXAMPLE 
PS> .\Get-FilesByExtension.ps1 -FolderPath 'C:\Windows' -FileExtension '.dll' 
#> 

param 
( 
    [parameter()][string] $FolderPath, 
    [parameter()][string] $FileExtension 
) 

$Result = (Test-Path($FolderPath)); 

If ($Result) 
{ 
    $Dir = get-childitem $FolderPath -recurse 
    $List = $Dir | where {$_.extension -eq $FileExtension} 
    $List | format-table Name 
} 
else 
{ 
    "Folder path is incorrect." 
} 

function TestPath()  
{ 
    $FileExists = Test-Path $FolderPath 
    If ($FileExists -eq $True)  
    { 
        Return $true 
    } 
    Else  
    { 
        Return $false 
    } 
}
}