# Purpose: Set-GroupTag — Microsoft Intune endpoint management.
$OldTag = ""
$NewTag = "NewTag"

Try{
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Force -ErrorAction Stop
    Install-Module -Name WindowsAutoPilotIntune -Force -ErrorAction Stop
    Import-Module WindowsAutoPilotIntune -Force -ErrorAction Stop
}
Catch{
    $ErrorMessage = $_.Exception.Message
    Write-host $ErrorMessage -ForegroundColor Red
    $ModuleImport = $false
}

If ($ModuleImport){
    Connect-MSGraph
    $AutoPilotDevices = Get-AutopilotDevice
    ForEach-Object ($AutopilotDevice -in $AutoPilotDevices){
        If ($AutopilotDevice.groupTag -eq $OldTag){
            Try{
                $AutopilotDevice | Set-AutopilotDevice -groupTag $NewTag -ErrorAction Stop
                Write-host "Group tag changed for device $($AutopilotDevice.SerialNumber)"
            }
            Catch{
                Write-Error "Failed to change group tag for device $($AutopilotDevice.SerialNumber)"
                $ErrorMessage = $_.Exception.Message
                Write-host $ErrorMessage -ForegroundColor Red
            }
        }
    }
}