# Purpose: LCMResourceDebug — Core infrastructure automation scripts.
#in V5 use: Enable-DscDebug -cimsession target -breakall
[DscLocalConfigurationManager()]
Configuration ConfigureLCMForDebug
{
    param([string[]]$computername)
    Node $computername
    {
        Settings
        {
            DebugMode = "ResourceScriptBreakAll"
            #DebugMode = 'None'
        RefreshMode = 'Push'
       # CertificateID ='BE5F7E5D18F44C51C2B491802F8C7CE314A0739F' 


        }
    }
}

$computer = "testsrv9"
ConfigureLCMForDebug -computername $computer

Set-DscLocalConfigurationManager -Path .\ConfigureLCMForDebug -Verbose -ComputerName $computer