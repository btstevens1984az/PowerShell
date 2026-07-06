# Purpose: SimpleRepadminSyncAll — General-purpose PowerShell utilities.
function Invoke-ReplicateDomainDCs {
$dcs = get-addomaincontroller  -Filter * 
$dcs.hostname | ForEach-Object { Repadmin /syncall $_ /Aed }
}
#New-Alias -Name ReplAll -Value Invoke-ReplicateDomainDCs

Invoke-ReplicateDomainDCs