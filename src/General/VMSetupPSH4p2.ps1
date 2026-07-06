# Purpose: VMSetupPSH4p2 — General-purpose PowerShell utilities.
If (Test-Path c:\VMs\VMs\WIN8-WS)
{$Vmpath ="C:\VMs\Vms"}
elseif(test-path "F:\vms\Common\2012R2-DC")
{
    $VmpathCommon ="F:\VMs\Common"
    $VmmPathWin8 = "F:\vms\part 2"
}
else
{throw "cannot find VMS"}


Get-vm | Stop-VM -Passthru | Remove-VM
Set-VMHost -EnableEnhancedSessionMode $true 

If (-not (Get-VMSwitch -Name internal -ErrorAction SilentlyContinue))
{
New-VMSwitch -Name Internal -SwitchType Internal -Verbose
}

$i = 0
while (-not (Get-VMSwitch -Name internal -ErrorAction SilentlyContinue))
{
    $i++
    Start-Sleep -Seconds 1
    if ($i -gt 10)
    {
        throw "Issue waiting for Virtual Switch creation"

    }
}
Import-VM -Path "$VmpathCommon\2012R2-DC\Virtual Machines\4EA83798-BB77-40FA-86C8-549C67C28E42.XML" -verbose
Import-VM -Path "$VmpathCommon\2012R2-MS\Virtual Machines\5EAB4707-0F7A-4332-97C6-ED166E00000F.XML" -verbose
 Import-VM -Path "$VmmPathWin8\WIN8-WS\Virtual Machines\202C4EEA-216D-4FAE-8507-4BA738B302BC.XML" -verbose


Get-VM | Set-VM -DynamicMemory -ProcessorCount 2 -MemoryStartupBytes 2GB -MemoryMaximumBytes 4GB -Passthru | Start-VM

