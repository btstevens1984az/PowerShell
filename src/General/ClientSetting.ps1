# Purpose: ClientSetting — General-purpose PowerShell utilities.
# Get the different Client settings Names
 $a = Get-CMClientSetting | select Name

foreach ($a in $a ) 
{
# Get all possible values for the Get-CMClientSetting -Setting parameter
$xsettings = [Enum]::GetNames( [Microsoft.ConfigurationManagement.Cmdlets.ClientSettings.Commands.SettingType])
 
# dump the detailed configuration settings

write-host $a.Name -foregroundcolor "magenta"

foreach ($xsettings in $xsettings ) {
        Get-CMClientSetting -Setting $xsettings -Name $a.Name | ft
    }
}