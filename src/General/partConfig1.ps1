# Purpose: partConfig1 — General-purpose PowerShell utilities.
configuration SimpleConfig
{
    Import-DscResource -ModuleName My_NewService -ModuleVersion 1.2.2
    node "localhost"
    {
        My_NewService spooler
        {
            Name = "spooler"
            State = 'stopped'
        }
        My_NewService Netlogon
        {
            Name = "Netlogon"
            State = 'Running'
        }
        File Temp
        {
            Type = 'Directory'
            DestinationPath = 'C:\temp'
            Ensure = 'Present'
        }

    }
}
simpleconfig

$ConfigPullPAth = '\\26.203.196.214\C$\Program Files\WindowsPowerShell\DSCService\Configuration'
$Destination = "$ConfigPullPAth\SimpleConfig.mof"
Copy-Item -Path .\SimpleConfig\localhost.mof -Destination $Destination -Verbose
New-DscChecksum $Destination -Force -Verbose

