# Purpose: AzureRBWconfig — Microsoft Azure cloud resource management.
configuration AzureAuto
{
    param([parameter()][string[]]$features = @('RSAT','Telnet-Client'),
           [parameter()][string[]]$node = @("Runbookworker","Runbookworker2")   )
    Import-DscResource –Module 'PSDesiredStateConfiguration'
    
    node $node
    {
        foreach ($feature in $features)
        {
            WindowsFeature $Feature
            {
                Name = $feature
                Ensure = 'Present'
                IncludeAllSubFeature = $true
            }
        }
    }
}
#$features = @('RSAT','Telnet-Client')
#AzureAuto -features $features -node Runbookworker