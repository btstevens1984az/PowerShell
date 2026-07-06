# Purpose: VMMTenantAdminWorkAround — General-purpose PowerShell utilities.
#this assumes dynamic memory is being used
#TODO - Handle VM that is running
#Add reprompting when bad values are given, create seperate function(s)
function Set-CustomVMSettings
{
[cmdletbinding()]
param(
        [parameter(Mandatory=$false)]
        [string]$vmmServer = "Scvmm2012"
)
$VMM = Get-SCVMMServer -ComputerName $vmmServer 
$cloudNames = Get-SCCloud -VMMServer $vmmServer | Select -ExpandProperty name
$cloudobjs = $cloudNames | %{[pscustomobject]@{Cloud=$_}}
$CloudName = ($cloudobjs| Out-GridView -OutputMode Single -Title "Pick a cloud to target" ).cloud
if (!$cloudName){
Write-verbose "No Cloud Selected, exiting"
Exit
}

$cloud = Get-SCCloud -Name $CloudName -VMMServer $VMM
$VMS = Get-SCVirtualMachine -Cloud $cloud -VMMServer $VMM
$VmToChange = $VMS | Select-Object -Property name,Computername,CPUCount,Memory,DynamicMemoryMaximumMB,DynamicMemoryMinimumMB,VMID |
  Out-GridView -Title "Pick VM to modify" -OutputMode Single
  if (!$VmToChange){
Write-verbose "No VM Selected, exiting script"
Exit
}

$VmToChange  = Get-SCVirtualMachine -name ($VmToChange.name) -VMMServer $vmm -Cloud $cloud 
$VMSettings = @{
                                CPUCount = $VmToChange.CPUCount
                                MemoryMB = $VmToChange.memory #Startup Memory
                                DynamicMemoryMaximumMB = $VmToChange.DynamicMemoryMaximumMB
                                DynamicMemoryMinimumMB = $VmToChange.DynamicMemoryMinimumMB
                                }
[validateScript({
                    if(-not $_)
                    {$true}
                    elseif ($_ -ge 1 -and $_ -le 64)
                    {$true}
                    Else
                    {$false}
                }                
)][int]$CPUCount  = Read-Host "Enter the Number of CPUs, Current value is $($VmToChange.CPUCount) <leave blank to not change>" -ErrorAction SilentlyContinue
[validateScript({
                    if(-not $_)
                    {$true}
                    elseif ($_ -ge 512 -and $_ -le 65536)
                    {$true}
                    Else
                    {$false}
                }                
)][int]$StartUpMemory = read-host "Startup Memory in MB, Current Value: $($VmToChange.memory) <leave blank to not change>" -ErrorAction SilentlyContinue
[validateScript({ 
                    if(-not $_)
                    {$true}
                    elseif ($StartUpMemory -and ($_ -lt $StartUpMemory ))
                    {
                        Write-error "Maximum memory can't be less than startup memory"
                        $false
                    }
                    elseif ($startupMemory -eq $null -and $_ -lt $VmToChange.memory)
                    {
                         Write-error "Maximum memory can't be less than startup memory"
                        $false
                    }
                    else
                    {$true}


})][int]$DynamicMemoryMaximumMB = read-host "Maximum Memory in MB, Current Value: $($VmToChange.DynamicMemoryMaximumMB) <leave blank to not change> "
[validateScript({ 
                    if (-not $_)
                    {$true}
                    elseif ($StartUpMemory -and ($_ -gt $StartUpMemory ))
                    {
                        Write-error "Minimum memory can't be more than startup memory"
                        $false
                    }
                    elseif ($startupMemory -eq $null -and( $_ -ge $VmToChange.memoryMB))
                    {
                         Write-error "Minimum memory can't be more than startup memory"
                        $false
                    }
                    else
                    {$true}

})][int]$DynamicMemoryMinimumMB = read-host "Minimum Memory in MB, Current Value: $($VmToChange.DynamicMemoryMinimumMB) <leave blank to not change> "

write-verbose "old Setting: "
write-verbose ("CPUCount: "+ $vmsettings.CPUCount)
write-verbose ("StartupMemory: " + $vmsettings.MemoryMB)
write-verbose ("DynamicMemoryMaximumMB: "+ $vmsettings.DynamicMemoryMaximumMB)
write-verbose ("DynamicMemoryMinimumMB: "+ $vmsettings.DynamicMemoryMinimumMB)

If ($CPUCount)
{$vmSettings.CPUCount = $CPUCount}
if ($StartUpMemory)
{$VMSettings.memoryMB = $StartUpMemory}
if ($DynamicMemoryMaximumMB)
{$VMSettings.DynamicMemoryMaximumMB = $DynamicMemoryMaximumMB}
if ($DynamicMemoryMinimumMB)
{$VMSettings.DynamicMemoryMinimumMB = $DynamicMemoryMinimumMB }

#$vmsettings.VMID = $VmToChange.ID
write-verbose "`nNew Settings:"
$VmToChange | Set-SCVirtualMachine @VMSettings -Verbose | select name,CPUcount,memory,DynamicMemoryMaximumMB,DynamicMemoryMinimumMB

}

Set-CustomVMSettings -Verbose