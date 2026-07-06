# Purpose: PSAlias — General-purpose PowerShell utilities.
﻿
$file = Get-ChildItem -Path . -Filter *.txt

$file | Add-Member -MemberType AliasProperty -Name Size -Value length
#$file.Size
$file | Format-Table name,size,Length -AutoSize

$file | gm -MemberType AliasProperty