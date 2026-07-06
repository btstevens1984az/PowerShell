# Purpose: Create-Files — Storage management and disk operations.
1..10 | % {New-Item -Path "C:\PShell\Labs\Lab_15\OriginalFiles\Security_2013_$_.log" -ItemType file }
1..10 | % {New-Item -Path "C:\PShell\Labs\Lab_15\OriginalFiles\Database_2012_$_.log" -ItemType file }
1..10 | % {New-Item -Path "C:\PShell\Labs\Lab_15\OriginalFiles\Reports_2013_$_.log" -ItemType file }
1..10 | % {New-Item -Path "C:\PShell\Labs\Lab_15\OriginalFiles\Security_2012_$_.log" -ItemType file }
1..10 | % {New-Item -Path "C:\PShell\Labs\Lab_15\OriginalFiles\Keep_2011_$_.log" -ItemType file }
1..10 | % {New-Item -Path "C:\PShell\Labs\Lab_15\OriginalFiles\Keep_2010_$_.log" -ItemType file }
1..10 | % {New-Item -Path "C:\PShell\Labs\Lab_15\OriginalFiles\Security_2014_$_.log" -ItemType file }