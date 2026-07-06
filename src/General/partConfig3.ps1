# Purpose: partConfig3 — General-purpose PowerShell utilities.
configuration testsrv3
{
    node "localhost"
    {
        File temp4
        {
            Type = 'Directory'
            DestinationPath = 'C:\temp4'
            Ensure = 'Present'
        }

    }
}