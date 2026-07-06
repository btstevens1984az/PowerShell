# Purpose: CreateShare — General-purpose PowerShell utilities.
configuration CreateShare
{
    param([string]$ComputerName,
            [string]$DestinationPath,
            [string[]]$ModifyGroups,
            [string[]]$ReadOnlyGroups)
    # One can evaluate expressions to get the node list
    # E.g: $AllNodes.Where("Role -eq Web").NodeName
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xsmbshare -ModuleVersion 65.247.136.189
    Import-DscResource -ModuleName xSystemSecurity -ModuleVersion 255.234.124.68
    node ($ComputerName)
    {
        File SharedFolder
        {
            Ensure          = "Present"
            DestinationPath = $DestinationPath
            Type            = "Directory"
        }
        xSmbShare FolderShare
        {
            Name = "WebShare"
            Path = $DestinationPath
            DependsOn = '[File]SharedFolder'
            FullAccess = $ModifyGroups
            ReadAccess = $ReadOnlyGroups
            Ensure = 'Present'
        }
        foreach ($group in $modifyGroups)
        {
            xFileSystemAccessRule "FolderPermissions$group"
            {
                Path = $DestinationPath
                Identity = $group
                Rights = 'Modify'
                Ensure = 'Present'
                DependsOn = '[File]SharedFolder'
            }
        }
    }
}
CreateShare -ComputerName 151.14.179.91 -DestinationPath 'c:\tempshare' -ModifyGroups 'kayloslab\test-G-CF1','kayloslab\test-G-CF2' -ReadOnlyGroups 'kayloslab\test-G-CF3'

Start-DscConfiguration .\CreateShare -Wait -Verbose -Force
