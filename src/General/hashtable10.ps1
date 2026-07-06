# Purpose: hashtable10 — General-purpose PowerShell utilities.
$hash = @{}
$array = @()

# Measure the elapsed time when adding to a hashtable versus an array. 

Measure-Command -Expression {1..2555 | %{$hash.Add(�192.168.0.$_�,0)}}
Measure-Command -Expression {1..2555 | %{$array+= �192.168.0.$_�}} 

# and when looking up a value 
Measure-Command -Expression { 1..2555 | % {$hash.ContainsKey("192.168.0.$_")} }
Measure-Command -Expression { 1..2555 | % {$array -contains "192.168.0.$_"} }

# and when accessing directly with a known index
Measure-command -expression {$hash["192.168.0.2555"]}
Measure-command -expression {$array[2554]}

