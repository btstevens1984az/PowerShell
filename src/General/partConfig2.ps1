# Purpose: partConfig2 — General-purpose PowerShell utilities.
configuration AllConfig
{
    node "localhost"
    {
        File Temp3
        {
            Type = 'Directory'
            DestinationPath = 'C:\temp3'
            Ensure = 'Present'
        }

    }
}
Allconfig
$ConfigPullPAth = "\\36.200.8.253\DscService\Configuration"
$Destination = "$ConfigPullPAth\AllConfig.mof"
Copy-Item -Path .\AllConfig\localhost.mof -Destination $Destination -Verbose
New-DscChecksum $Destination -Force -Verbose