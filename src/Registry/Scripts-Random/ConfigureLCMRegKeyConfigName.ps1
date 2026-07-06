# Purpose: ConfigureLCMRegKeyConfigName — Windows registry read and write operations.
[DSCLocalConfigurationManager()]
Configuration LCM_HTTPSPULL 
{
    param
        (
            [Parameter(Mandatory=$true)]
            [string[]]$ComputerName,

            [Parameter(Mandatory=$false)]
            [string]$RegistrationKey = "d042bd0b-bff8-4657-8f53-7b052f8d3a58",
            
            [Parameter(Mandatory=$false)]
            [string]$PullServerUrl = 'https://dscpullv5.kaylos.lab:8080/PSDSCPullServer.svc',

            [Parameter(Mandatory=$false)]
            [string]$CertificateID = 'BB287A7573177A5DA2E319C9E0D3C82AA39476C7'


        )      	
	Node $ComputerName {
	
		Settings{
		     
			AllowModuleOverwrite = $True
            ConfigurationMode = 'ApplyAndAutoCorrect'
			RefreshMode = 'Pull'
            CertificateID = $CertificateID
			#ConfigurationID = $guid
            }

            ConfigurationRepositoryWeb DSCHTTPS {
                ServerURL = $PullServerUrl
                #CertificateID = $CertificateID
                AllowUnsecureConnection = $false
                RegistrationKey = $RegistrationKey
                ConfigurationNames =@('webserver')
            }	
            ReportServerWeb HTTPReport
            {
                ServerURL = $PullServerUrl
                RegistrationKey = $RegistrationKey
                AllowUnsecureConnection =$false
            }
	}
}

$computers = "testsrv4","testsrv5"
Foreach ($computer in $computers)
{
    $thumbprint = icm -ScriptBlock {(dir Cert:\LocalMachine\My -DocumentEncryptionCert).Thumbprint} -ComputerName $computer
    LCM_HTTPSPull -ComputerName $computer -CertificateID $thumbprint
    $thumbprint = $null
}


Set-DscLocalConfigurationManager -Path .\LCM_HTTPSPULL -Verbose 
Update-DscConfiguration -ComputerName $computers -Wait -Verbose
Start-DscConfiguration -CimSession $computers -Wait -Verbose -UseExisting




