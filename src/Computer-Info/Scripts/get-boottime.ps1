# Purpose: get-boottime — Computer hardware and system inventory.
$computername=$env:computername

$os=Get-WmiObject win32_operatingsystem -computername $computername

Write-Host ("Last boot: {0}" -f $os.ConvertToDateTime($os.lastbootuptime))
Write-Host ("Uptime   : {0}" -f ((get-date) - $os.ConvertToDateTime($os.lastbootuptime)).tostring())
