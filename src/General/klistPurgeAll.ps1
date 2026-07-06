# Purpose: klistPurgeAll — General-purpose PowerShell utilities.
#http://regexhero.net/tester/
#ISERegEX
$regex = "0x[0-9a-f]+"
$sessions = klist sessions | Select-String -Pattern $regex | %{$_.matches} | %{$_.value}
#PSH V3 alternative: $sessions = (klist sessions | Select-String -Pattern $regex).matches.value
#Uncomment next line to purge kerberos tickets for all sessions. Can quote klist command to see what commands it would have run.
$sessions | Select-Object -Unique |ForEach-Object {"klist purge -li $_"} 

