# Purpose: Config HTTPSPullServer — Core infrastructure automation scripts.
configuration HTTPPullServer
{
    param([string[]]$nodename)
    # Modules must exist on target pull server
    Import-DSCResource -ModuleName xPSDesiredStateConfiguration

    Node $nodename
    {
        WindowsFeature DSCServiceFeature
        {
            Ensure = "Present"
            Name   = "DSC-Service"
        }

        WindowsFeature IISConsole {
            Ensure = "Present"
            Name   = "Web-Mgmt-Console"
        }
        windowsFeature DFSR {
            Ensure = "Present"
            Name   = "FS-DFS-Replication"
        }
        
        xDscWebService PSDSCPullServer
        {
            Ensure                  = "Present"
            EndpointName            = "PSDSCPullServer"
            Port                    = 8080
            PhysicalPath            = "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer"
            CertificateThumbPrint   = '3FFE8900875A0704E72E22DD0FA39153B0921C75'
            ModulePath              = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
            ConfigurationPath       = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
            State                   = "Started"
            DependsOn               = "[WindowsFeature]DSCServiceFeature"
        }

        xDscWebService PSDSCComplianceServer
        {
            Ensure                  = "Present"
            EndpointName            = "PSDSCComplianceServer"
            Port                    = 9080
            PhysicalPath            = "$env:SystemDrive\inetpub\wwwroot\PSDSCComplianceServer"
            CertificateThumbPrint   = "AllowUnencryptedTraffic"
            State                   = "Started"
            IsComplianceServer      = $true
            DependsOn               = ("[WindowsFeature]DSCServiceFeature","[xDSCWebService]PSDSCPullServer")
        }
    }
}

# Generate MOF

HTTPPullServer -OutputPath C:\DSC\HTTP -nodename "dscpull1","dscpull2"
Start-DscConfiguration -path c:\dsc\http -Verbose -Wait -Force

