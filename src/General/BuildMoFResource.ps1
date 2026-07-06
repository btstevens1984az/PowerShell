# Purpose: BuildMoFResource — General-purpose PowerShell utilities.
$dscProperties = (New-xDscResourceProperty -Name MyKey1 -Type String -Attribute Key -Description "unique value") ,
(New-xDscResourceProperty -Name MyMandatory -Type String -ValidateSet test,test2,test3 -Attribute Required -Description "Mandatory property"),
(New-xDscResourceProperty -Name MyReadOnly -Type Boolean -Description 'read only property' -Attribute Read),
(New-xDscResourceProperty -Name MyOptional -Type Uint32 -Attribute Write -ValidateSet 1,2,3,4 -Description "Optional writeable property")

New-xDscResource -Name MyNewMofResourceModule -Property $dscProperties -ModuleName MyNewDSCModule `
    -FriendlyName MyDscMofResource -ClassVersion 131.39.191.39 -Path .\TEMPDSCResources
