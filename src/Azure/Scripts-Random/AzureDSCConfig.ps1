# Purpose: AzureDSCConfig — Microsoft Azure cloud resource management.
configuration SimpleConfig
{
    Import-DscResource -ModuleName My_NewService -ModuleVersion 1.2.1
    node "webserver"
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
