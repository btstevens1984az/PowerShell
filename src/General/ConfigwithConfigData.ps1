# Purpose: ConfigwithConfigData — General-purpose PowerShell utilities.

$configData = @{
    AllNodes = @(
        @{
            NodeName = "*"
            #Role = "WebServer"
            AllFeatures = @('telnet-client','XPS-Viewer')
            
            },
        @{
            NodeName = "web1"
            Role = "WebServer"
            },
        @{
            NodeName = "web2"
            Role = "WebServer"
            },
                    @{
            NodeName = "web3"
            Role = "WebServer"
            },
                    @{
            NodeName = "sql1"
            Role = "SQL"
            },
                    @{
            NodeName = "sql2"
            Role = "SQL"
            },
            @{
            NodeName = "sql3"
            Role = "SQL"
            }

    )
    NonNodeData = @{
                Baseline = "1.0"
    
                }
}
configuration MyConfigs
{
    # One can evaluate expressions to get the node list
    # E.g: $AllNodes.Where("Role -eq Web").NodeName
    node $AllNodes.NodeName
    {

       foreach($feature in $node.allfeatures)
        {
            WindowsFeature $feature
            {
               Ensure = "Present"
               Name   = $feature
            }
        }
       if ($node.role -eq "WebServer")
       {

        WindowsFeature 'Web-Mgmt-Console'
            {
               Ensure = "Present"
               Name   = 'Web-Mgmt-Console'
            }
       }
       elseif($node.role -eq "SQL")
       {
            WindowsFeature "telnet-Server"
            {
               Ensure = "Present"
               Name   = "telnet-Server"
            }

       }

        File BuildVersionFile
        {
            Ensure          = "Present"
            #SourcePath      = $SourcePath
            DestinationPath = $DestinationPath
            Type            = 'File'
            Contents = $ConfigurationData.NonNodeData.Baseline
        }
        
    }
}

Myconfigs -ConfigurationData $configData
