# Purpose: ExploreRegistryProvider — Windows registry read and write operations.
#.\scripts\v1\demoScripts\Providers_ch3
#about_Core_Commands
#about_Providers
#exploring the registry provider
Set-Location HKCU:\
Set-Location software
new-item test
Set-Location test
#The registry propertytypes are "String, ExpandString, Binary, DWord, MultiString, QWord"
New-ItemProperty -Path . -name newvalue -value "string"
#alias Get-ItemProperty
(Get-itemproperty HKCU:\software\test).newvalue
New-ItemProperty . -name BinaryTest -value 1 -PropertyType Binary
New-ItemProperty . -name DwordValue -value 20 -PropertyType DWord
New-ItemProperty . -name newvalueint64 -value 10000000000 -PropertyType QWORD
New-ItemProperty . -name strings2 -value "string","string2" -PropertyType multistring
Remove-ItemProperty . newvalueint64 #remove-itemproperty # can use wildcard to delete all values
set-itemproperty . -name newvalue -value "another string"
Set-ItemProperty . newvalue "yet another string"
mkdir test1
mkdir test2
mkdir test3
Remove-Item * -confirm
Set-Location c:
(Get-ItemProperty HKCU:\software\test).newvalue
Set-ItemProperty HKCU:\software\test newvalue "something else"
Remove-Item HKCU:\software\test