# Purpose: BackUpFiles — Storage management and disk operations.
# ------------------------------------------------------------------------
# DATE: 12/12/2008
#
# KEYWORDS: Filesystem, get-childitem, where-object
# date manipulation, regular expressions
#
# COMMENTS: This script backs up a folder. It will
# back up files that have been modified within the past 
# 24 hours. You can change the interval, the destination, 
# and the source. It creates a back up folder that is named based upon
# the time the script runs. If the destination folder does not exist, it
# will be created. The destination folder is based upon the time the 
# script is run and will look like this: C:\bu\12.12.2008.1.22.51.PM.
# The interval is the age in days of the files to be copied.
#
# ---------------------------------------------------------------------
Function New-back upFolder($destinationFolder)
{
 #Receives the path to the destination folder and creates the path to 
 #a child folder based upon the date / time. It then calls the New-back up
 #function while passing the source path, destination path, and interval
 #in days. 
 $dte = get-date
 #The following regular expression pattern removes white space, colon, and
 #forward slash from the date and replaces with a period to create the
 #back up folder name. 
 $dte = $dte.tostring() -replace "[:\s/]", "."
 $back upPath = "$destinationFolder" + $dte
 $null = New-Item -path $back upPath -itemType directory
 New-back up $dataFolder $back upPath $back upInterval
} #end New-back upFolder

Function New-back up($dataFolder,$back upPath,$back upInterval)
{
 #Does a recursive copy of all files in the data folder and filters out
 #all files that have been written to within the number of days specified
 #by the interval. Writes copied files to the destination and will create 
 #if the destination (including parent path) does not exist. Will overwrite
 #if destination already exists. This is unlikely, however, unless the 
 #script is run twice during the same minute. 
 "backing up $dataFolder... check $back uppath for your files"
 Get-Childitem -path $dataFolder -recurse |
 Where-Object { $_.LastWriteTime -ge (get-date).addDays(-$back upInterval) } |
 Foreach-Object { copy-item -path $_.FullName -destination $back upPath -force }
} #end New-back up

# *** entry point to script ***

$back upInterval = 1
$dataFolder = "C:\fso"
$destinationFolder = "C:\BU\"
New-back upFolder $destinationFolder

