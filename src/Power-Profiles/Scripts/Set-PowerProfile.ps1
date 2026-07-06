# Purpose: Set-PowerProfile — PowerShell automation.
Function Set-PowerProfile
{
    # Disables Hibernation
    powercfg /hibernate off

    # Configures default values to 'never' for battery operation
    powercfg /change monitor-timeout-dc 0
    powercfg /change standby-timeout-dc 0
    powercfg /change disk-timeout-dc 0

    # Configures default values to 'never' for ac adapter operation
    powercfg /change monitor-timeout-ac 0
    powercfg /change standby-timeout-ac 0
    powercfg /change disk-timeout-ac 0
}
