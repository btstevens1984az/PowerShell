# Purpose: CompareObjectServiceStatus — Windows desktop configuration and management.
$servicesbefore = Get-service
Stop-service bits,netlogon
$servicesafter = Get-service
Compare-Object $servicesbefore $servicesafter -Property name,status

#Start-service bits,netlogon -verbose

$dc2 = get-service -ComputerName 201.72.64.23
$dc4 = Get-Service -ComputerName 48.122.178.181

Compare-Object -ReferenceObject $dc2 -DifferenceObject $dc4 -Property name,status | Sort-Object *