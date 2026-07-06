# Purpose: CreateWebsite — General-purpose PowerShell utilities.
Configuration CreateWebSite
{
    Param(
            
            [string]$ComputerName='localhost',
            [parameter(Mandatory)] 
            [string]$WebSiteName,
            [parameter(Mandatory)]
            [string]$WebSitePath,
            [parameter(Mandatory)]
            [string]$DestinationPath,
            [parameter(Mandatory)]
            [string[]]$ModifyGroups,
            [string[]]$ReadOnlyGroups)

    Import-DscResource -ModuleName xWebAdministration -ModuleVersion 210.231.146.72
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xsmbshare -ModuleVersion 65.247.136.189
    Import-DscResource -ModuleName xSystemSecurity -ModuleVersion 255.234.124.68
    Import-DscResource -ModuleName xCertificate -ModuleVersion 33.189.201.215
    node ($ComputerName)
    {
       <# xCertReq SSLCert
        {
            CAServerFQDN = 'pkiroot.kaylos.lab'
            Subject = 'testsrv7.kaylos.kab'
            CARootName = 'PKIROOT'
            KeyLength = '4096'
            OID = '1.3.6.1.5.5.7.3.1'
            #KeyUsage  = '0xa0'
            ProviderName = '"Microsoft RSA SChannel Cryptographic Provider"'
            CertificateTemplate = 'Web Server 2'
            AutoRenew = $true
            #SubjectAltName 
        }
        #>
        File SharedFolder
        {
            Ensure          = "Present"
            DestinationPath = $DestinationPath
            Type            = "Directory"
        }
        xSmbShare FolderShare
        {
            Name = "WebShare"
            Path = $DestinationPath
            DependsOn = '[File]SharedFolder'
            FullAccess = $ModifyGroups
            ReadAccess = $ReadOnlyGroups
            Ensure = 'Present'
        }
        foreach ($group in $modifyGroups)
        {
            xFileSystemAccessRule "FolderPermissions$group"
            {
                Path = $DestinationPath
                Identity = $group
                Rights = 'Modify'
                Ensure = 'Present'
                DependsOn = '[File]SharedFolder'
            }
        }

        File WebSiteFolder
        {
            Ensure          = "Present"
            SourcePath = $DestinationPath
            DestinationPath = $WebSitePath
            Type            = "Directory"
            Recurse = $true
            DependsOn = '[File]SharedFolder'
        }
        WindowsFeature IIS
        {
            Ensure          = 'Present'
            Name            = 'Web-Server'
        }

        # Install the ASP .NET 4.5 role
        WindowsFeature AspNet45
        {
            Ensure          = 'Present'
            Name            = 'Web-Asp-Net45'
        }
        WindowsFeature Web-Mgmt-Console
        {
            Ensure = 'Present'
            Name   = 'Web-Mgmt-Console'

        }
        xWebsite $WebSiteName
        {
            Ensure          = 'Present'
            Name            = $WebSiteName
            State           = 'Started'
            PhysicalPath    = $DestinationPath
            DependsOn       = '[File]WebSiteFolder','[WindowsFeature]IIS','[WindowsFeature]AspNet45','[File]SharedFolder'
            BindingInfo =  @(    MSFT_xWebBindingInformation
                                 {
                                   Protocol              = "HTTPS"
                                   Port                  = 8443
                                   CertificateThumbprint ='8801A1EC283BE630D51C0FEC53C62377CDD3B548'
                                   CertificateStoreName  = "My"
                                   IPAddress             = '*'
                                 }
                                 MSFT_xWebBindingInformation
                                 {
                                   Protocol              = "HTTP"
                                   Port                  = 8444
                                   IPAddress             = '*'
                                 }
                            )
        }


    }


}

$ConfigParams = @{
                    WebSiteName ='testsrv7'
                    ComputerName= 'testsrv7'
                    DestinationPath = 'c:\tempshare'
                    ModifyGroups ='kayloslab\test-G-CF1','kayloslab\test-G-CF2'
                    ReadOnlyGroups = 'kayloslab\test-G-CF3' 
                    WebSitePath ='c:\website1'




            }

CreateWebSite  @ConfigParams
#Start-DscConfiguration .\CreateWebSite -Wait -Verbose -Force
<# 
 @( MSFT_xWebBindingInformation
                                 {
                                   Protocol              = "HTTPS"
                                   Port                  = 8443
                                   CertificateThumbprint ="71AD93562316F21F74606F1096B85D66289ED60F"
                                   CertificateStoreName  = "WebHosting"
                                 }
                                 MSFT_xWebBindingInformation
                                 {
                                   Protocol              = "HTTPS"
                                   Port                  = 8444
                                   CertificateThumbprint ="<thumbprint2>"
                                   CertificateStoreName  = "WebHosting"
                                 }
#>