# Purpose: Manage-StorageAccount — PowerShell automation.
Function Manage-StorageAccount
{
# Script to set the storage account as managed by the keyvault and add a sastoken to the keyvault

# Resource names
$resourceGroupName = ''
$storageAccountName = ''
$keyVaultName = ''

# Subscription and tenant IDs
$subscriptionId = ''
$tenantId = ''

# Permissions to grant current user on the keyvault
$userVaultPermissions = @{
    PermissionsToKeys         = @(
        'get',
        'create',
        'delete',
        'list',
        'update',
        'import',
        'backup',
        'restore',
        'recover'
    )
    PermissionsToSecrets      = @(
        'get',
        'list',
        'set',
        'delete',
        'backup',
        'restore',
        'recover'
    )
    PermissionsToCertificates = @(
        'get',
        'delete',
        'list',
        'create',
        'import',
        'update',
        'deleteissuers',
        'getissuers',
        'listissuers',
        'managecontacts',
        'manageissuers',
        'setissuers',
        'recover',
        'backup',
        'restore'
    )
    PermissionsToStorage      = @(
        'delete',
        'deletesas',
        'get',
        'getsas',
        'list',
        'listsas',
        'regeneratekey',
        'set',
        'setsas',
        'update',
        'recover',
        'backup',
        'restore'
    )
}

# Non-deployment specific script variables
$keyVaultApplicationId = 'cfa8b339-82a2-471a-a3c9-0fc0be7a4093' # This is the same for all tenants
$keyVaultRoleDefinition = 'Storage Account Key Operator Service Role' # This is the same for all tenants
$storageAccountKey = 'key1' # key1 or key2
$keyVaultRegeneratePeriod = '3' # days
$sasTokenValidityPeriod = '30' # days

# Import required module, clean any current contexts and connect to Azure
Import-Module Az
Clear-AzContext -Scope Process
Clear-AzContext -Scope CurrentUser -Force -ErrorAction SilentlyContinue
Connect-AzAccount -UseDeviceAuthentication

# Set current context to the required subscription and tenant
Set-AzContext -SubscriptionId $subscriptionId -TenantId $tenantId

# Get the storage account
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -StorageAccountName $storageAccountName

# If Azure role doesn't exist on the KeyVault then create it
$existingRole = Get-AzRoleAssignment -RoleDefinitionName $keyVaultRoleDefinition -Scope $storageAccount.Id -ErrorAction SilentlyContinue
if (!($existingRole)) {
    New-AzRoleAssignment -ApplicationId $keyVaultApplicationId -RoleDefinitionName $keyVaultRoleDefinition -Scope $storageAccount.Id
}

# Set permissions for current user on KeyVault
$currentUserId = (Get-AzContext).Account.Id
Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName -ResourceGroupName $resourceGroupName -UserPrincipalName $currentUserId @userVaultPermissions

# Make storage account key vault managed
Add-AzKeyVaultManagedStorageAccount -VaultName $keyVaultName -AccountName $storageAccount.StorageAccountName -AccountResourceId $storageAccount.Id -ActiveKeyName $storageAccountKey -RegenerationPeriod ([System.Timespan]::FromDays($keyVaultRegeneratePeriod))

# Generate SAS token for managed storage account and add to key vault
$storageContext = New-AzStorageContext -StorageAccountName $storageAccount.StorageAccountName -Protocol 'Https' -StorageAccountKey 'key1'
$sasToken = New-AzStorageAccountSasToken -Service 'blob,file,Table,Queue' -ResourceType 'Service,Container,Object' -Permission 'racwdlup' -Protocol 'HttpsOnly' -Context $storageContext
Set-AzKeyVaultManagedStorageSasDefinition -AccountName $storageAccount.StorageAccountName -VaultName $keyVaultName -Name 'sastoken' -TemplateUri $sasToken -SasType 'account' -ValidityPeriod ([System.Timespan]::FromDays($sasTokenValidityPeriod))

# Disconnect from Azure
Disconnect-AzAccount
}