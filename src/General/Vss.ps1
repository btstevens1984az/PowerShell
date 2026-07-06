# Purpose: Vss — General-purpose PowerShell utilities.
#text to objects
$delimiter = ":"
$VSSWriters = vssadmin list writers
#Skip first 3 lines and remove empty lines
$VSSWriters = $VSSWriters | select-object -skip 3 | ? {$_ -like "*:*"}
For ($i=0;$i-le ($VSSWriters.Count-1);$i = $I+5)
{
    $writerName =$VSSWriters[$i] -split $delimiter 
    $writerID =$VSSWriters[$i+1] -split $delimiter
    $writerInstanceID =$VSSWriters[$i+2] -split $delimiter
    $writerState =$VSSWriters[$i+3] -split $delimiter
    $writerLastError =$VSSWriters[$i+4] -split $delimiter
    $objHash = @{
                "WriterName"=$writerName[1] 
                "WriterID"=$writerID[1]
                "WriterInstanceID"=$writerInstanceID[1]
                "State"=$writerState[1]
                "LastError"=$writerLastError[1]
                }
    new-object  -TypeName PSobject -Property $objHash 
    $objHash = $null
}