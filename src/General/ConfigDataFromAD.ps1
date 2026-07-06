# Purpose: ConfigDataFromAD — General-purpose PowerShell utilities.
$computers = Get-ADComputer -Properties * -Filter *
$configData = @{ AllNodes = @(
                                    @{
                                        NodeName = "*"
                                        #Role = "WebServer"
                                        AllFeatures = @('telnet-client','XPS-Viewer')
            
                                        })
                NonNodeData = @{
                                 Baseline = "1.0"
                               }
                }

foreach ( $comp in $computers)
{
    $configData.AllNodes += @{
                                NodeName = $comp.name
                                OS = $comp.OperatingSystem

                            }

}

configuration MyConfigs
{
    # One can evaluate expressions to get the node list
    # E.g: $AllNodes.Where("Role -eq Web").NodeName
    node $AllNodes.where({$_.os -like "*server*"}).nodename
    {

       foreach($feature in $node.allfeatures)
        {
            WindowsFeature $feature
            {
               Ensure = "Present"
               Name   = $feature
            }
        }
       if ($node.os -like "*2016*")
       {

        WindowsFeature 'Web-Mgmt-Console'
            {
               Ensure = "Present"
               Name   = 'Web-Mgmt-Console'
            }
       }
       elseif($node.OS -like "*2012*")
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

MyConfigs -ConfigurationData $configData 
#$configData.AllNodes.where({ $_.os -Like "*2016*"})