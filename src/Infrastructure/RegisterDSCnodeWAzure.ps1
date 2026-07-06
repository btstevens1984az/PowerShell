# Purpose: RegisterDSCnodeWAzure — Core infrastructure automation scripts.
# The DSC configuration that will generate metaconfigurations
[DscLocalConfigurationManager()]
Configuration DscMetaConfigs 
{ 
    param 
    ( 
        [Parameter(Mandatory=$True)] 
        [String]$RegistrationUrl,

        [Parameter(Mandatory=$True)] 
        [String]$RegistrationKey,

        [Parameter(Mandatory=$True)] 
        [String[]]$ComputerName,

        [Int]$RefreshFrequencyMins = 30, 

        [Int]$ConfigurationModeFrequencyMins = 15, 

        [String]$ConfigurationMode = "ApplyAndMonitor", 

        [String[]]$NodeConfigurationName,

        [Boolean]$RebootNodeIfNeeded= $False,

        [String]$ActionAfterReboot = "ContinueConfiguration",

        [Boolean]$AllowModuleOverwrite = $False,

        [Boolean]$ReportOnly
    )

    if(!$NodeConfigurationName -or $NodeConfigurationName -eq "") 
    { 
        $ConfigurationNames = $null 
    } 
    else 
    { 
        $ConfigurationNames = @($NodeConfigurationName) 
    }

    if($ReportOnly)
    {
       $RefreshMode = "PUSH"
    }
    else
    {
       $RefreshMode = "PULL"
    }

    Node $ComputerName
    {

        Settings 
        { 
            RefreshFrequencyMins = $RefreshFrequencyMins 
            RefreshMode = $RefreshMode 
            ConfigurationMode = $ConfigurationMode 
            AllowModuleOverwrite  = $AllowModuleOverwrite 
            RebootNodeIfNeeded = $RebootNodeIfNeeded 
            ActionAfterReboot = $ActionAfterReboot 
            ConfigurationModeFrequencyMins = $ConfigurationModeFrequencyMins 
        }

        if(!$ReportOnly)
        {
           ConfigurationRepositoryWeb AzureAutomationDSC 
            { 
                ServerUrl = $RegistrationUrl 
                RegistrationKey = $RegistrationKey 
                ConfigurationNames = $ConfigurationNames 
            }

            ResourceRepositoryWeb AzureAutomationDSC 
            { 
               ServerUrl = $RegistrationUrl 
               RegistrationKey = $RegistrationKey 
            }
        }

        ReportServerWeb AzureAutomationDSC 
        { 
            ServerUrl = $RegistrationUrl 
            RegistrationKey = $RegistrationKey 
        }
    } 
}

# Create the metaconfigurations
# TODO: edit the below as needed for your use case
$Params = @{
     RegistrationUrl = '<put url here>';
     RegistrationKey = '<put key here>';
     ComputerName = @('hybridrun1');
     NodeConfigurationName = @('AzureAuto.RunbookWorker','AllConfig.general');
     RefreshFrequencyMins = 30;
     ConfigurationModeFrequencyMins = 15;
     RebootNodeIfNeeded = $False;
     AllowModuleOverwrite = $False;
     ConfigurationMode = 'ApplyAndAutoCorrect';
     ActionAfterReboot = 'ContinueConfiguration';
     ReportOnly = $False;  # Set to $True to have machines only report to AA DSC but not pull from it
}

# Use PowerShell splatting to pass parameters to the DSC configuration being invoked
# For more info about splatting, run: Get-Help -Name about_Splatting
DscMetaConfigs @Params
#Set-DscLocalConfigurationManager -Path .\DscMetaConfigs -Verbose 