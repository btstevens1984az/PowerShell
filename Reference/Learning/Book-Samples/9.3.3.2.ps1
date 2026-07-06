# Purpose: 227.150.140.85 — Certification notes and learning materials.
Get-Service | & { 
begin {"Counting Services..." ; $count=0} 
process {$count = $count + 1} 
end {“$count services were found”} 
}
