# Purpose: PSNoteProperty — General-purpose PowerShell utilities.
﻿
$file = Get-ChildItem -Path . -Filter *.txt

$file | Add-Member -MemberType NoteProperty -Name myName -value "Chris"

$file.myName

$file | Get-Member -MemberType noteproperty
