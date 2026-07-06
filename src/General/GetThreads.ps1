# Purpose: GetThreads — General-purpose PowerShell utilities.
﻿
$name = "explorer"
$processHandle = (Get-Process -Name $name).id

$Threads = Get-WmiObject -Class Win32_Thread |
Where-Object { $_.ProcessHandle -eq $processHandle }

"The $name process has $($threads.count) threads"
$threads | Format-Table -Property priority, thread*, User*Time, kernel*Time