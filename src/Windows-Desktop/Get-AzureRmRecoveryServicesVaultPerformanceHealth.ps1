<#
    .SYNOPSIS
       Check your Azure Recovery Services vault performance health state.
    .DESCRIPTION
       Check your Azure Recovery Services vault performance health state.
       The Power Shell script checks the current usage of all Azure Recovery Services vaults in one Azure subscription.
        File Name : Get-AzureRmStoragePerformanceHealth.ps1
        Requires  : AzureRm PowerShell Cmdlets
    .LINK
        To provide feedback or for further assistance visit:
        http://www.danielstechblog.info
    .EXAMPLE
       Get-AzureRmRecoveryServicesVaultPerformanceHealth

       Runs the script.
#>
#Azure login
$azureEnvironment=Get-AzureRmEnvironment|Out-GridView -Title "Select the Azure environment" -PassThru

$null=Login-AzureRmAccount -EnvironmentName $azureEnvironment.Name

$subscription=Get-AzureRmSubscription|Out-GridView -Title "Select the Azure subscription" -PassThru
$null=Select-AzureRmSubscription -SubscriptionId $subscription.Id -Verbose

#Variables
$recoveryServicesVaultArray=@()
$recoveryServicesVaultVMLimit=1000
$backupPolicyVMLimit=40

$recoveryServicesVaults=Get-AzureRmRecoveryServicesVault -Verbose
foreach($recoveryServicesVault in $recoveryServicesVaults)
{
    Set-AzureRmRecoveryServicesVaultContext -Vault $recoveryServicesVault -Verbose
    $backupPolicies=Get-AzureRmRecoveryServicesBackupProtectionPolicy -Verbose
    $backupPolicyArray=@()
    foreach($backupPolicy in $backupPolicies)
    {
        $Info = New-Object PSObject -Property @{
            PolicyName=$backupPolicy.Name
            PolicyVMCount=0
        }
        $backupPolicyArray += $Info
    }

    $vaultVMs=Get-AzureRmRecoveryServicesBackupContainer -ContainerType AzureVM -BackupManagementType AzureVM -Verbose

    $Info = New-Object PSObject -Property @{
        RecoveryServicesVault=$recoveryServicesVault.Name
        PolicyName=""
        VaultVMCount=$vaultVMs.Length
        PolicyVMCount=""
        StatusVault=if([math]::Round(($vaultVMs.Length/$recoveryServicesVaultVMLimit)*100) -gt 900){"NEAR LIMIT"}else{"OK"}
        StatusPolicy=""
    }
    $recoveryServicesVaultArray += $Info

    foreach($vaultVM in $vaultVMs)
    {
        $backupItem=Get-AzureRmRecoveryServicesBackupItem -Container $vaultVM -WorkloadType AzureVM -Verbose
        foreach($item in $backupPolicyArray)
        {
            if($item.PolicyName -eq $backupItem.ProtectionPolicyName)
            {
                $count=$item.PolicyVMCount
                $count+=1
                $index=[array]::indexof($backupPolicyArray.PolicyName,$backupItem.ProtectionPolicyName)
                $backupPolicyArray[$index].PolicyVMCount=$count
            }
        }
    }

    foreach($item in $backupPolicyArray)
    {
        $Info = New-Object PSObject -Property @{
            RecoveryServicesVault=""
            PolicyName=$item.PolicyName
            VaultVMCount=""
            PolicyVMCount=$item.PolicyVMCount
            StatusVault=""
            StatusPolicy=if(($item.PolicyVMCount) -gt $backupPolicyVMLimit){"WARNING"}else{"OK"}
        }
        $recoveryServicesVaultArray += $Info
    }
}

$recoveryServicesVaultArray|Select-Object -Property @{Label="Recovery Services vault name";Expression={"{0:N0}" -f ($_.RecoveryServicesVault)}},@{Label="Backup Policy name";Expression={"{0:N0}" -f ($_.PolicyName)}},@{Label="Recovery Services vault VM count";Expression={"{0:N0}" -f ($_.VaultVMCount)}},@{Label="Backup Policy VM count";Expression={"{0:N0}" -f ($_.PolicyVMCount)}},@{Label="Recovery Services vault status";Expression={"{0:N0}" -f ($_.StatusVault)}},@{Label="Backup Policy status";Expression={"{0:N0}" -f ($_.StatusPolicy)}}|Out-GridView -Title "Recovery Services vault performance status"