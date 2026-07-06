<#
.Synopsis
   This function allows you to quickly search for files with common criteria
.DESCRIPTION
   The Find-Files function utilizes Get-ChildItem and Where-Object. This function allows you to craft queries on your local filesystem to locate forgotten files recursively.
   
   The Parameters you can search by are as follows:
     -Path
     -FileType
     -Exclusions
     -LastTimeModified
.PARAMETER Path
    The Path of the directory the search begins
.PARAMETER FileType
    The file extension to be retrieved.  Some examples are "exe" "txt" "docx"
.PARAMETER Exclusions
    Any string to be excluded in the name.  Some examples are "draft" or "final"
.PARAMETER LastTimeModified
    Filter for how long ago the item was edited.  If it was edited in the last week, the number would be 7.  For month, 30.
.EXAMPLE
   This will search for all txt files in the GitHub folder updated in the last week.

   Find-Files -Path "C:\Temp" -FileType "txt" -LastTimeModified 7
.EXAMPLE
   This will search for files that do not include the word draft updated in the last month

   Find-Files -Path C:\MyApplication\Documentation -Exclude "draft" -LastTimeModified 30
#>
Function Find-FilesByAgeType
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   Position=0)]
        $Path,

        # Param2 help description
        [Parameter(Mandatory=$false,
                   Position=1)]
        $FileType="*",
        # Param3 help description
        [Parameter(Mandatory=$false,
                   Position=2)]
        $Exclude,
        # Param4 help description
        [Parameter(Mandatory=$false,
                   Position=3)]
        $LastTimeModified
    )

$date = Get-Date
$date = $date.AddDays(-$LastTimeModified)

$query = If (!$LastTimeModified) {
        If (!$Exclude) {
            Get-ChildItem -Path $Path -Recurse -Include "*.$FileType"
        } else {
            Get-ChildItem -Path $Path -Recurse -Include "*.$FileType" -Exclude "*$Exclude*"
        }
    } else {
        If (!$Exclude) {
            Get-ChildItem -Path $Path -Recurse -Include "*.$FileType" | Where-Object { $_.LastWriteTime -gt $date }
        } else {
            Get-ChildItem -Path $Path -Recurse -Include "*.$FileType" -Exclude "*$Exclude*" | Where-Object { $_.LastWriteTime -gt $date }
        }
    }

    return $query

}