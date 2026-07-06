# Purpose: Get-RIDPoolCount — General-purpose PowerShell utilities.
$RidManagerPath = 'CN=RID Manager$,CN=System,DC=Contoso,DC=com'
$RID = Get-ADObject -Identity $RidManagerPath -Properties rIDAvailablePool

[int32]$totalSIDS = $RID.rIDAvailablePool / ([math]::Pow(2,32))
[int64]$temp64 = $totalSIDS * ([math]::Pow(2,32))
[int32]$currentRidPoolCount = $RID.rIDAvailablePool - $temp64

$ridsremaining = $totalSIDS - $currentRidPoolCount