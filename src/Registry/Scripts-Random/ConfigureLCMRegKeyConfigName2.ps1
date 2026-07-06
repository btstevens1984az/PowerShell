# Purpose: ConfigureLCMRegKeyConfigName2 — Windows registry read and write operations.
[DSCLocalConfigurationManager()]
Configuration LCM_HTTPSPULL 
{
    param
        (
            [Parameter(Mandatory=$true)]
            [string[]]$ComputerName,

            [Parameter(Mandatory=$false)]
            [string]$RegistrationKey = "d5b9ea36-b7e5-4258-8c1f-a7f43ea0991f",
            
            [Parameter(Mandatory=$false)]
            [string]$PullServerUrl = 'https://pull2.kaylos.lab:8080/PSDSCPullServer.svc',

            [Parameter(Mandatory=$false)]
            [string]$CertificateID = 'BB287A7573177A5DA2E319C9E0D3C82AA39476C7'


        )      	
	Node $ComputerName {
	
		Settings{
		     
			AllowModuleOverwrite = $True
            ConfigurationMode = 'ApplyAndMonitor'
			RefreshMode = 'Pull'
            CertificateID = $CertificateID
			#ConfigurationID = $guid
            }

            ConfigurationRepositoryWeb DSCHTTPS {
                ServerURL = $PullServerUrl
                #CertificateID = $CertificateID
                AllowUnsecureConnection = $false
                RegistrationKey = $RegistrationKey
                ConfigurationNames =@('SimpleConfig')
            }	
            ReportServerWeb HTTPReport
            {
                ServerURL = $PullServerUrl
                RegistrationKey = $RegistrationKey
                AllowUnsecureConnection =$false
            }
	}
}

$computers = "testsrv1","testsrv2"
Foreach ($computer in $computers)
{
    $thumbprint = icm -ScriptBlock {(dir Cert:\LocalMachine\My -DocumentEncryptionCert).Thumbprint} -ComputerName $computer
    LCM_HTTPSPull -ComputerName $computer -CertificateID $thumbprint
    $thumbprint = $null
}


Set-DscLocalConfigurationManager -Path .\LCM_HTTPSPULL -Verbose 
Update-DscConfiguration -ComputerName $computers -Wait -Verbose
#Start-DscConfiguration -CimSession $computers -Wait -Verbose -UseExisting




