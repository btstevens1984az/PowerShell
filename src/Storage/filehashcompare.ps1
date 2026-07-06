# Purpose: filehashcompare — Storage management and disk operations.
$HashFile = dir c:\temp -Recurse | Where-Object {-not $_.PSiscontainer} | Group-Object name -AsHashTable
$HashFile2 = dir c:\temp2 -Recurse | Where-Object {-not $_.PSiscontainer} |  Group-Object name -AsHashTable

foreach ($file in $hashfile.keys)
{

    if (-not $HashFile2.ContainsKey($file))
    {
        "$file is not in directory 2"
        "$($hashfile[$file].fullname)"
    }


}