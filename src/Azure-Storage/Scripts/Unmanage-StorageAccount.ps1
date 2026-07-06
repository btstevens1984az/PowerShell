# Purpose: Unmanage-StorageAccount — PowerShell automation.
Function Unmanage-StorageAccount
{
# Script to set the storage account as managed by the keyvault and add a sastoken to the keyvault

# Resource names
$resourceGroupName = ''
$storageAccountName = ''
$keyVaultName = ''

# Subscription and tenant IDs
$subscriptionId = ''
$tenantId = ''

# Import required module, clean any current contexts and connect to Azure
Import-Module Az
Clear-AzContext -Scope Process
Clear-AzContext -Scope CurrentUser -Force -ErrorAction SilentlyContinue
Connect-AzAccount -UseDeviceAuthentication

# Set current context to the required subscription and tenant
Set-AzContext -SubscriptionId $subscriptionId -TenantId $tenantId

# Get the storage account
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -StorageAccountName $storageAccountName

# Remove the KeyVault managed SAS definition
Get-AzKeyVaultManagedStorageSasDefinition -AccountName $storageAccount.StorageAccountName -VaultName $keyVaultName | Remove-AzKeyVaultManagedStorageSasDefinition

# Remove the KeyVault management for the storage account
Remove-AzKeyVaultManagedStorageAccount -VaultName $keyVaultName -AccountName $storageAccount.StorageAccountName

# Check management has been removed
Get-AzKeyVaultManagedStorageAccount -VaultName $keyVaultName -AccountName $storageAccount.StorageAccountName

# Check if management remains in soft deleted form
Get-AzKeyVaultManagedStorageAccount -VaultName $keyVaultName -AccountName $storageAccount.StorageAccountName -InRemovedState

# Remove soft deleted management
Remove-AzKeyVaultManagedStorageAccount -VaultName $keyVaultName -AccountName $storageAccount.StorageAccountName -InRemovedState

# Disconnect from Azure
Disconnect-AzAccount
}