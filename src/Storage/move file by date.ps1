# Purpose: move file by date — Storage management and disk operations.

dir |? {$_.LastWriteTime -lt (get-date).AddHours(-8)} | del -whatif

dir |? {$_.CreationTime -lt (get-date).AddHours(-8)} | del -whatif



get-childitem -recurse | where-object { $_.CreationTime -ilt
[datetime]::now.adddays(-120) } | move-item -destination 'C:\tempmove\Location2'


ls [a-z]*.wav |
    Where {((get-date) - [datetime]::Parseexact($_.name.split('-')[1],"yyyyMMdd",$null)).days -gt 60} |
        Move-Item -WhatIf -Destination {'C:\dir\' + $_.name[0] + '\' + $_.name}