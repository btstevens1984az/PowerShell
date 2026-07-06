# Purpose: miscAzureCmds — General-purpose PowerShell utilities.
Get-AzureAccount
# -DeleteVHD will delete blob storage
Get-AzureDisk | Remove-AzureDisk -DeleteVHD -Verbose
Get-AzureStorageAccount | where location -eq "West US" | Remove-AzureStorageAccount -Verbose