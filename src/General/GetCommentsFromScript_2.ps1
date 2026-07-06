# Purpose: GetCommentsFromScript 2 — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 3/7/2009
#
# KEYWORDS: Join-Path, Split-Path, [io.path],
# Get-Content, regular expression, Out-File
# COMMENTS: This script reads the text of a script and
# retrieves comments that are placed within here strings.
# Each comment is a here string that is assigned to the 
# variable $comment. It will look like the following: 
# $Comment = @"
# The regex pattern: ^\$comment\s?=\s?@" matches
# the above. The caret ^ is the beginning of the line.
# \ escapes the $ which is a special character. \s? is
# white space with zero or one repeat.
# _2 Added routine to backup a previous version of the 
# output file, by renaming it to .old if it exists. 
# Windows PowerShell Best Practices
# ------------------------------------------------------------------------
Param($Script= $(throw "The path to a script is required."))
Function Get-FileName($Script)
{
 $OutPutPath = [io.path]::GetTempPath()
 Join-Path -path $OutPutPath -child "$(Split-Path $script -leaf).txt"
} #end Get-FileName

Function Remove-OutPutFile($OutPutFile)
{
  if(Test-Path -path $OutPutFile) 
    {
       $Response = Read-Host -Prompt "$OutPutFile already exists. Do you wish to delete it <y / n>?"
       if($Response -eq "y")
         { Remove-Item $OutPutFile | Out-Null }
       ELSE 
         {
           if(Test-Path -path "$OutPutFile.old") { Remove-Item -Path "$OutPutFile.old" }
           Rename-Item -path $OutPutFile -newname  "$(Split-Path $OutPutFile -leaf).old" -Force
          }
    }
} #end Remove-OutPutFile

Function Get-Comments($Script,$OutPutFile)
{
 Get-Content -path $Script |
 Foreach-Object `
  { 
    If($_ -match '^\$comment\s?=\s?@"')
     { 
      $beginComment = $True 
     } #end if match @"
   If($_ -match '"@')
     { 
      $beginComment = $False
     } #end if match "@
   If($beginComment -AND $_ -notmatch '@"') 
     {
      $_ | Out-File -FilePath $OutPutFile -append
     } # end if beginComment
  } #end Foreach
} #end Get-Comments

Function Get-OutPutFile($OutPutFile)
{
 Notepad $OutPutFile
} #end Get-OutPutFile

# *** Entry point to script ***
$OutPutFile = Get-FileName($script)
Remove-OutPutFile($OutPutFile)
Get-Comments -script $script -outputfile $OutPutFile
Get-OutPutFile($OutPutFile)
