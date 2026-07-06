# Purpose: ConfigurePullServerv5 — Core infrastructure automation scripts.
# DSC configuration for Pull Server
# Prerequisite: Certificate "CN=PSDSCPullServerCert" in "CERT:\LocalMachine\MY\" store
# Note: A Certificate may be generated using MakeCert.exe: http://msdn.microsoft.com/en-us/library/windows/desktop/aa386968%28v=vs.85%29.aspx
# This version sets the RegistrationKeyPath which is where registration keys are stored. It also installs the native module that allows for the
# acceptance of self-signed certificates in IIS.

configuration Configure_xDscWebService
{
    param 
    (
        [string[]]$NodeName = 'localhost',
        [ValidateNotNullOrEmpty()]
        [string] $certificateThumbPrint,
        [Parameter(HelpMessage='This should be a string with enough entropy (randomness) to protect the registration of clients to the pull server.  We will use new GUID by default.')]
        [ValidateNotNullOrEmpty()]
        [string] $RegistrationKey = ([guid]::NewGuid()).Guid
    )
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 108.199.79.239

    Node $NodeName
    {
        WindowsFeature DSCServiceFeature
        {
            Ensure = "Present"
            Name   = "DSC-Service"            
        }

        xDscWebService PSDSCPullServer
        {
            Ensure                  = "Present"
            EndpointName            = "PSDSCPullServer"
            Port                    = 8080
            PhysicalPath            = "$env:SystemDrive\inetpub\PSDSCPullServer"
            CertificateThumbPrint   = $certificateThumbPrint         
            ModulePath              = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
            ConfigurationPath       = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"            
            State                   = "Started"
            DependsOn               = "[WindowsFeature]DSCServiceFeature" 
            RegistrationKeyPath     = "$env:PROGRAMFILES\WindowsPowerShell\DscService"   
           
        }
        File RegistrationKeyFile
        {
            Ensure          ='Present'
            Type            = 'File'
            DestinationPath = "$env:ProgramFiles\WindowsPowerShell\DscService\RegistrationKeys.txt"
            Contents        = $RegistrationKey
            DependsOn       = '[xDSCWebService]PSDSCPullServer'
        }
    }
 }
 $computerName  = "dscpullv5"
 $SSLCert  = invoke-command -ScriptBlock { dir Cert:\LocalMachine\My -SSLServerAuthentication} -ComputerName  $computerName
 If ($SSLCert.count -eq 1)
 {
 $session = New-PSSession -ComputerName $computerName
  if ( -not (icm -ScriptBlock { Get-module -name xPSDesiredStateConfiguration -ListAvailable  } -Session $session ))
  {
    icm { Install-Module xPSDesiredStateConfiguration -Repository psGallery -Force -Scope AllUsers} -Session $session
  }

  Configure_xDscWebService -NodeName $computerName -certificateThumbPrint $SSLCert.Thumbprint -OutputPath .\DSCPull
  Remove-PSSession -Session $session
 }
 #Sometimes have to run twice if terminating error occurs on first run.
 Start-DscConfiguration -Path .\DSCPull -Wait -Verbose -Force
