# Purpose: ConfigureHTTPSPullLCM PSH5 — Core infrastructure automation scripts.
[DSCLocalConfigurationManager()]
Configuration LCM_HTTPSPULL 
{
    param
        (
            [Parameter(Mandatory=$true)]
            [string[]]$ComputerName,

            [Parameter(Mandatory=$true)]
            [string]$guid,
            
            [Parameter(Mandatory=$false)]
            [string]$PullServerUrl = 'https://dscpull.kaylos.lab:8080/PSDSCPullServer.svc',

            [Parameter(Mandatory=$false)]
            [string]$CertificateID = 'D09D21D12916BFB09B40E7568A7434A6EABFD9BA'


        )      	
	Node $ComputerName {
	
		Settings{
		     
			AllowModuleOverwrite = $True
            ConfigurationMode = 'ApplyAndAutoCorrect'
			RefreshMode = 'Pull'
			ConfigurationID = $guid
            }

            ConfigurationRepositoryWeb DSCHTTPS {
                ServerURL = $PullServerUrl
                CertificateID = 'D09D21D12916BFB09B40E7568A7434A6EABFD9BA'
                AllowUnsecureConnection = $false
            }
		
	}
}

# Computer list 
$ComputerName=1..5 | % {"testsrv$_"}
$adcomputers = $ComputerName | %{Get-ADComputer -Identity $_}
# Create Guid for the computers
#$guid=[guid]::NewGuid()

# Create the Computer.Meta.Mof in folder
$ADcomputers | %{LCM_HTTPSPULL -ComputerName $_.name -Guid $_.ObjectGUID.guid -OutputPath "c:\DSC\HTTP\"}

Set-DSCLocalConfigurationManager -ComputerName $adcomputers.name -Path c:\DSC\HTTP –Verbose






