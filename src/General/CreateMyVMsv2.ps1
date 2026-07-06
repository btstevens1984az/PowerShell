#TODO - Cleanup temporary templates and hardware profiles or avoid creating them.
#How to avoid creating temporary template and set correct computer name?

<#
.SYNOPSIS
Creates new VMs with SCVMM. Useful for creating multiple VMs with the same settings.
.DESCRIPTION new VMs with SCVMM. Useful for creating multiple VMs with the same settings.
.PARAMETER vmmserver
SCVMM Server Name
.PARAMETER NewComputerName
One or more computer names for the new VMs.
.PARAMETER cloudName
VMM cloud name
.PARAMETER delayStart
VM delay start value in seconds
.PARAMETER templateName
SCVMM template name
.PARAMETER multi
Enabled creating many VMs with the same computer prefix and a number range for the suffixes. I.e. testsrv1,testsrv2 etc
.PARAMETER beginNumber
When using multi, begining number suffix for the computer name
.PARAMETER endNumber
Ending number suffix for computer names.
.PARAMETER PipelineVariable

.EXAMPLE
PS C:\> New-MyVM -NewComputerName "testsrv" -multi -beginNumber 1 -endNumber 10 -Template 2012r2wPSH5 -delaystart 200 -cloudName "Kaylos Lab"
Creates 10 VMs testsrv1..10
NAME        :  New-MyVM
LAST UPDATED:  5/7/2015
.INPUTS
None
.OUTPUTS
None
#>
function new-MyVM{
[cmdletbinding(DefaultParameterSetName='Single')]
param(
[parameter(ParameterSetName='Single')]
[parameter(ParameterSetName='Multi')]
[string]$vmmserver = "scvmm2012.kaylos.lab",
[parameter( Mandatory=$true, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
[string[]]$NewComputerName,
[parameter(ParameterSetName='Single')]
[parameter(ParameterSetName='Multi')]
[string]$cloudName = "Kaylos Lab",
[parameter(ParameterSetName='Single')]
[parameter(ParameterSetName='Multi')]
[int32]$delayStart = 250,
[parameter(ParameterSetName='Single')]
[parameter(ParameterSetName='Multi')]
[string]$templateName = "Win2012R2Gen2",
[Parameter(ParameterSetName='Multi')]
[switch]$multi,
[Parameter(ParameterSetName='Multi')]
[int32]$beginNumber=1,
[parameter(Mandatory=$true,ParameterSetName='Multi')]
[ValidateRange(1,50)]
[int32]$endNumber
)
process
{
    if($multi)
    {       
        $NewComputerName = $beginNumber..$endNumber | %{"$NewComputerName$_"}
    }
    foreach ($computerName in $NewComputerName)
    {
    Write-Verbose "Create new VM: $computerName"
    $jobGroup1 = [guid]::NewGuid()
    $jobGroup2 = [guid]::NewGuid()
    $tempProfile = "Profile$([guid]::NewGuid())"
    $tempTemplate ="Temp Template $([guid]::NewGuid())"
    New-SCVirtualScsiAdapter -VMMServer $vmmserver -JobGroup $jobGroup1 -AdapterID 7 -ShareVirtualScsiAdapter $false -ScsiControllerType DefaultTypeNoType 
    New-SCVirtualDVDDrive -VMMServer $vmmserver -JobGroup $jobGroup1 -Bus 0 -LUN 1 
    $VMNetwork = Get-SCVMNetwork -VMMServer $vmmserver -Name "kaylos" -ID "3a224fa8-da43-4454-8385-85a86bd4130c"
    New-SCVirtualNetworkAdapter -VMMServer $vmmserver -JobGroup $jobGroup1 -MACAddressType Dynamic -VLanEnabled $false -Synthetic -EnableVMNetworkOptimization $false -EnableMACAddressSpoofing $false -EnableGuestIPNetworkVirtualizationUpdates $false -IPv4AddressType Dynamic -IPv6AddressType Dynamic -VMNetwork $VMNetwork 
    $CPUType = Get-SCCPUType -VMMServer $vmmserver | where {$_.Name -eq "3.60 GHz Xeon (2 MB L2 cache)"}
    $CapabilityProfile = Get-SCCapabilityProfile -VMMServer $vmmserver | where {$_.Name -eq "Hyper-V"}
    $HardwareProfile = New-SCHardwareProfile -VMMServer $vmmserver -CPUType $CPUType -Name $tempProfile -Description "Profile used to create a VM/Template" -CPUCount 2 -MemoryMB 512 -DynamicMemoryEnabled $true -DynamicMemoryMinimumMB 512 -DynamicMemoryMaximumMB 4096 -DynamicMemoryBufferPercentage 20 -MemoryWeight 5000 -CPUExpectedUtilizationPercent 20 -DiskIops 0 -CPUMaximumPercent 100 -CPUReserve 0 -NumaIsolationRequired $false -NetworkUtilizationMbps 0 -CPURelativeWeight 100 -HighlyAvailable $false -DRProtectionRequired $false -SecureBootEnabled $true -CPULimitFunctionality $false -CPULimitForMigration $false -CapabilityProfile $CapabilityProfile -Generation 2 -JobGroup $jobGroup1 
    $Template = Get-SCVMTemplate -VMMServer $vmmserver -name "$templateName"
    #$HardwareProfile = Get-SCHardwareProfile -VMMServer $vmmserver | where {$_.Name -eq $tempProfile}
    $LocalAdministratorCredential = get-scrunasaccount -VMMServer "$vmmserver" -Name "Jeff" -ID "7ef37f63-cd5e-4db1-b7dd-6679dd74a137"
    $OperatingSystem = Get-SCOperatingSystem -VMMServer $vmmserver -ID "6f8f058d-918e-4eca-bf8d-3c2ac1d7c747" | where {$_.Name -eq "Windows Server 2012 R2 Datacenter"}
    $template = New-SCVMTemplate -Name $tempTemplate -Template $Template -HardwareProfile $HardwareProfile -JobGroup b7069103-63a0-452a-96a6-d3d50c3b585a -ComputerName $computerName -TimeZone 20 -LocalAdministratorCredential $LocalAdministratorCredential  -AnswerFile $null -OperatingSystem $OperatingSystem 
    #$template = Get-SCVMTemplate -All | where { $_.Name -eq $tempTemplate }
    $virtualMachineConfiguration = New-SCVMConfiguration -VMTemplate $template -Name $computerName
    #Write-Output $virtualMachineConfiguration
    $cloud = Get-SCCloud -Name $cloudName
    New-SCVirtualMachine -Name $computerName -VMConfiguration $virtualMachineConfiguration -Cloud $cloud -Description "" -JobGroup $jobGroup2 -ReturnImmediately -StartAction "TurnOnVMIfRunningWhenVSStopped" -StopAction "SaveVM" -DelayStartSeconds $delayStart -StartVM
    Write-Verbose "Creatation of new VM: $computerName job finished, wait for job to complete."
    Start-Sleep -Seconds 5
    }
}

}