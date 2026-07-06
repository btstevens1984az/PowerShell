# Purpose: Split-Collection — Configuration Manager collections and deployments.
function Split-Collection {
    param (
    [string]$CollectionName,
    [string]$NummberOfCollections
    )
    $Devices = Get-CMDevice -CollectionName $CollectionName
    $NumberOfDevices = $Devices.Count
    $NumberOfDevicesPerCollection = [math]::ceiling($NumberOfDevices / $NummberOfCollections)

    for ($i=1; $i -le $NummberOfCollections; $i++){
        $NewCollectionName = "Example Collection $i"
        New-CMDeviceCollection -Name $NewCollectionName -LimitingCollectionName $CollectionName

        $NewDevices = Get-Random -InputObject $Devices -Count $NumberOfDevicesPerCollection
        foreach ($NewDevice in $NewDevices) {
            Add-CMDeviceCollectionDirectMembershipRule -CollectionName $NewCollectionName -Resource $NewDevice
        }

        $Devices = $Devices | Where-Object { $NewDevices -notcontains $_ }
        $NumberOfDevicesLeft = $Devices.Count
        $NummberOfCollectionsLeft = $NummberOfCollections-$i
        if ($NummberOfCollectionsLeft -gt 0) {
            $NumberOfDevicesPerCollection = [math]::ceiling($NumberOfDevicesLeft / $NummberOfCollectionsLeft)
        }
    }
}