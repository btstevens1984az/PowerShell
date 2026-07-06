# Purpose: CCMCacheInfo — General-purpose PowerShell utilities.
Param(
  [string]$computer
)
$usedsize = Get-WMIObject -namespace root\ccm\softmgmtagent -query "Select ContentSize from CacheInfoEx" -ComputerName $computer
$currsize = Get-WMIObject -namespace root\ccm\softmgmtagent -query "Select Size from CacheConfig" -ComputerName $computer
$runningtotal=0
$total=0
Foreach ($obj in $usedsize)
{
$total = $obj.ContentSize
$runningtotal+=$total
}
Write-Host "Cache in use: $([math]::round($runningtotal / 1MB,2)) GB"
Write-Host "Total Cache Size: $([math]::round($currsize.Size / 1KB,2)) GB"