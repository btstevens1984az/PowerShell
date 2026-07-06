# Purpose: WriteBiosInfoToWord — Hardware and software inventory collection.

$class = "Win32_Bios"
$path = "C:\fso\bios"

#The wdSaveFormat object must be saved as a reference type. 
[ref]$SaveFormat = "microsoft.office.interop.word.WdSaveFormat" -as [type]

$word = New-Object -ComObject word.application
$word.visible = $true
$doc = $word.documents.add()
$selection = $word.selection
$selection.typeText("This is the bios information")
$selection.TypeParagraph()

Get-WmiObject -class $class | 
Out-String |
ForEach-Object { $selection.typeText($_) }
$doc.saveas([ref] $path, [ref]$saveFormat::wdFormatDocument)
$word.quit()