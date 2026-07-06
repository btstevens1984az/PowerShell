# Purpose: ConfigureHTTPSPullLCM PSH5 SingleConfigReboot — Core infrastructure automation scripts.
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
            RebootNodeIfNeeded = $true
            ActionAfterReboot = 'ContinueConfiguration'
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
$ComputerName=1..8 | % {"testsrv$_"}
$adcomputers = $ComputerName | %{Get-ADComputer -Identity $_}
# Create Guid for the computers
$guid="372a3afd-542d-4c9f-84d8-0293c3a14c09"
#Write-Host $guid

# Create the Computer.Meta.Mof in folder
$ADcomputers | %{LCM_HTTPSPULL -ComputerName $_.name -Guid $guid -OutputPath "c:\DSC\HTTP\"}
LCM_HTTPSPULL -ComputerName $_.name -Guid $guid -OutputPath "c:\DSC\HTTP\"
Set-DSCLocalConfigurationManager -ComputerName $adcomputers.name -Path c:\DSC\HTTP –Verbose






