# Purpose: SimpleRemoveOldComputersOutGrid — Windows desktop configuration and management.
$ADcomputers = Get-ADComputer -filter * -Properties lastlogondate | where{ $_.lastlogondate -lt ((Get-date).AddDays(-365) )}
$ADcomputers | sort lastlogondate | Out-GridView -PassThru |Remove-ADObject -Recursive -Confirm 