# Purpose: SaveWmiInformationAsDocument — PowerShell automation.
# ------------------------------------------------------------------------
# DATE: 1/26/2009
#
# KEYWORDS: Modular script, word, word.application
# script level variable, scoping, reference, ref
# COMMENTS: This is a modular script that creates a 
# new word document, queries wmi, creates a selection
# and creates a filename, and then saves the document
#
# ------------------------------------------------------------------------
Function CreateWordDoc()
{
  $script:word = New-Object -ComObject word.application
  $word.visible = $true
  $Script:doc = $word.documents.add()
} #end CreateWordDoc

Function CreateSelection($Heading)
{
  $script:selection = $word.selection
  $selection.typeText($Heading)
  $selection.TypeParagraph()
} #end CreateSelection

Function GetWmiData($WmiClass)
{
 Get-WmiObject -class $wmiClass | Out-String |
 ForEach-Object {$selection.typeText($_)}
} #end GetWmiData

Function CreateFilePath($wmiClass)
{
 $script:filename = $wmiClass.substring(6)
 $script:path = Join-Path -Path $folder -childpath $filename
} #end CreateFilePath

Function SaveWordData($path)
{
 [ref]$SaveFormat = "microsoft.office.interop.word.WdSaveFormat" -as [type]
 $doc.saveas([ref]$path, [ref]$saveFormat::wdFormatDocument)
 $word.quit()
} #end SaveWordData

# *** Entry point ***
$folder = "C:\fso"
$wmiClass = "Win32_Bios"
$heading = "$wmiClass information:"
CreateWordDoc
CreateSelection($Heading)
GetWmiData($wmiClass)
CreateFilePath($wmiClass)
SaveWordData($path)