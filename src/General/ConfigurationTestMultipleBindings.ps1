# Purpose: ConfigurationTestMultipleBindings — General-purpose PowerShell utilities.
configuration TestBinding
{
    Param($WebsiteName = "test",
          $DestinationPath = "C:\testweb",
          $Protocols = @("Http","https"),
          $BindingInfo,
          $nodename="Localhost"
            )

    Import-DscResource -ModuleName xWebAdministration -ModuleVersion 210.231.146.72
    node ($nodename)
    {
        xWebsite $WebSiteName
        {
            Ensure          = 'Present'
            Name            = $WebSiteName
            State           = 'Started'
            PhysicalPath    = $DestinationPath
            BindingInfo =  @(
                                Foreach ($binding in $bindingInfo)
                                {
                                    if($binding.protocol -eq 'http')
                                    {
                                        MSFT_xWebBindingInformation
                                        {
                                        Port                  = [UInt16]($binding.port)
                                        Protocol              = $binding.protocol
                                        IPAddress             = $binding.ipaddress
                                        HostName              = $binding.hostname
                                        }
                                    }
                                    else
                                    {
                                        MSFT_xWebBindingInformation
                                        {
                                        Port                  = [UInt16]($binding.port)
                                        Protocol              = $binding.protocol
                                        IPAddress             = $binding.ipaddress
                                        HostName              = $binding.hostname
                                        CertificateThumbprint = $binding.CertificateThumbprint
                                        CertificateStoreName  = $binding.CertificateStoreName
                                        }
                                    }
                                }
                            ) 

        }    
    }
}



$bindingInfo = @(
                @{
                    Protocol='Http'
                    Port = 8888
                    IpAddress='*'
                    HostName='TestHostName1'
                  },
                @{
                    Protocol='Https'
                    Port = 8889               
                    IpAddress='*'
                    HostName='TestHostName2'                
                    CertificateThumbprint = '8801A1EC283BE630D51C0FEC53C62377CDD3B548'
                    CertificateStoreName  = 'My'               
                }
                )

testbinding -BindingInfo $bindingInfo #-nodename testsrv7