# Purpose: AzureDSCConfig2 — Microsoft Azure cloud resource management.
configuration AllConfig
{
    node "General"
    {
        File Temp
        {
            Type = 'Directory'
            DestinationPath = 'C:\temp2'
            Ensure = 'Present'
        }

    }
}