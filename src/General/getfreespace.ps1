# Purpose: getfreespace — General-purpose PowerShell utilities.
gwmi Win32_logicalDisk -ComputerName $args |select-object __server,deviceID,freespace |ConvertTo-Html >freespace.htm