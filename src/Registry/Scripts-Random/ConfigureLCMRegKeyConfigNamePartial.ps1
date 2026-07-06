# Purpose: ConfigureLCMRegKeyConfigNamePartial — Windows registry read and write operations.
[DSCLocalConfigurationManager()]
Configuration LCM_HTTPSPULLPart 
{
    param
        (
            [Parameter(Mandatory=$true)]
            [string[]]$ComputerName,

            [Parameter(Mandatory=$false)]
            [string]$RegistrationKey = "d5b9ea36-b7e5-4258-8c1f-a7f43ea0991f",
            
            [Parameter(Mandatory=$false)]
            [string]$PullServerUrl = 'https://pull2.kaylos.lab:8080/PSDSCPullServer.svc',

            [Parameter(Mandatory=$true)]
            [string]$CertificateID 


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
                CertificateID = $CertificateID
                AllowUnsecureConnection = $false
                RegistrationKey = $RegistrationKey
                ConfigurationNames =@('AllConfig','SimpleConfig','testsrv3')
            }	
            ReportServerWeb HTTPReport
            {
                ServerURL = $PullServerUrl
                RegistrationKey = $RegistrationKey
                AllowUnsecureConnection =$false
            }

            PartialConfiguration AllConfig
            {
             Description = "General Service Config"
            ConfigurationSource = '[ConfigurationRepositoryWeb]DSCHTTPS'
            RefreshMode = 'Pull'

            #DependsOn = '[ConfigurationRepositoryWeb]DSCHTTPS'

            }
            PartialConfiguration SimpleConfig
            {
                Description = "WebServer Config"
                ConfigurationSource = '[ConfigurationRepositoryWeb]DSCHTTPS'
                RefreshMode = 'Pull'
                DependsOn = '[PartialConfiguration]AllConfig'
                #ExclusiveResources = 'File','registry'

            }
            
            PartialConfiguration testsrv3
            {
                Description = "testsrv3 Unique Config"
                ConfigurationSource = '[ConfigurationRepositoryWeb]DSCHTTPS'
                RefreshMode = 'Pull'
                DependsOn = '[PartialConfiguration]SimpleConfig'
            
            }
            
            

	}
}
$computers = "testsrv3"
Foreach ($computer in $computers)
{
    $thumbprint = icm -ScriptBlock {(dir Cert:\LocalMachine\My -DocumentEncryptionCert).Thumbprint} -ComputerName $computer
    LCM_HTTPSPullPart -ComputerName $computer -CertificateID $thumbprint
    $thumbprint = $null
}

#If LCM doesn't register with the pull server trying  running with -Force
Set-DscLocalConfigurationManager -Path .\LCM_HTTPSPULLPart -Verbose -Force

Update-DscConfiguration -CimSession $computers -Wait -Verbose

#The following will combine the partial configs and apply them
Start-DscConfiguration -Wait -UseExisting -CimSession $computers -Verbose

#Test-DscConfiguration -CimSession testsrv3,testsrv4,testsrv5 -Detailed
#
#Get-DscLocalConfigurationManager -CimSession testsrv4





