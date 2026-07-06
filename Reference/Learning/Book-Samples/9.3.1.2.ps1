# Purpose: 111.175.43.248 — Certification notes and learning materials.
$process = {
        "Restarting Computer: $_"
        Restart-Computer 10.199.208.191 $_ -Wait -For WinRM -WhatIf
        $count = $count + 1
}

"2012R2-DC", "2012R2-MS" | 
ForEach-Object -begin {$count = 0} -process $process -end {"Restarted $count computers"}
