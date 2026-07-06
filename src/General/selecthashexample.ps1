# Purpose: selecthashexample — General-purpose PowerShell utilities.
#$hash = @{name="SizeKB" ;expression={[system.math]::round((($_.length)/1KB),2)}}
$hash = @{name="Size" ;expression={
    if ($_.length -gt 1GB)
    { 
        "$(($_.length)/1GB)GB"
    }
    elseif ($_.length -gt 1MB)
    { "$([int](($_.length)/1MB))MB"}
    elseif ($_.length -gt 1KB)
    { "$([int](($_.length)/1KB))KB"}
    else
    {0}
    }
}
$files = Get-ChildItem -Recurse | Where-Object {$_.PSIsContainer -eq $false} 
$newfiles = $files | Select-object name,$hash | Sort-Object Size -Descending
$newfiles | ConvertTo-Html -CssUri C:\temp\example.css -Title "File Sizes" > c:\temp\files.htm 
