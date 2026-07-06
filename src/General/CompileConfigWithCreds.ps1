# Purpose: CompileConfigWithCreds — General-purpose PowerShell utilities.
$configdata = @{
	AllNodes = @(
		@{
			NodeName = '*'            PSDscAllowPlainTextPassword = $True
            PSDscAllowDomainUser = $True
		},
		@{
			NodeName = 'TestSrvConfig'
		}
	)
}
$splatParams=@{
    AutomationAccountName = 'Automation1'
    ConfigurationName = 'TestConfig2'
    ResourceGroupName  = 'Default-Storage-SouthCentralUS'
    ConfigurationData = $configdata
    #ConfigurationData = (Get-AzureRmAutomationJob -AutomationAccountName Automation1 -ResourceGroupName Default-Storage-SouthCentralUS -RunbookName AllowPasswords_Configuration_Data -Status Completed |Get-AzureRmAutomationJobOutput  | Get-AzureRmAutomationJobOutputRecord).value
    Parameters =  @{AzureAutoCredName="AzureRun"}
}


Start-AzureRmAutomationDscCompilationJob @splatParams