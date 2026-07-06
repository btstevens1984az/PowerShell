# Purpose: SearchForWordImages — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 11/4/2008
#
# KEYWORDS: Word.Application, automation, COM
# Get-Childitem -include, Foreach-Object 
#
# COMMENTS: This script searches a folder for doc and
# docx files, opens them with Word and counts the 
# number of images embedded in the file.
# It then prints out the name of each file and the
# number of associated images with the file. This script requires
# Word to be installed. It was tested with Word 2007. The folder must
# exist or the script will fail. 
#
# ------------------------------------------------------------------------
#The folder must exist and be followed with a trailing \*
$folder = "c:\fso\*"
$include = "*.doc","*.docx"
$word = new-object -comobject word.application
#Makes the Word application invisible. Set to $true to see the application.
$word.visible = $false
Get-ChildItem -path $folder -include $include |
ForEach-Object `
{
 $doc = $word.documents.open($_.fullname)
 $_.name + " has " + $doc.inlineshapes.count + " images in the file"
}
#If you forget to quit Word, you will end up with multiple copies running 
#at the same time. 
$word.quit()