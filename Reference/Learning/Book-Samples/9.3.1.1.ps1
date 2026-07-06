# Purpose: 101.188.94.48 — Certification notes and learning materials.
Get-Service | 
Foreach-Object –begin {"Counting Services..." ; $count=0} `
–process {$count = $count + 1} `
–end {“$count services were found”}