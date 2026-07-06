# Purpose: RegisterNodesWithAzureAutomation — Microsoft Azure cloud resource management.
#https://docs.microsoft.com/en-us/azure/automation/automation-dsc-onboarding
 # Define the parameters for Get-AzureRmAutomationDscOnboardingMetaconfig using PowerShell Splatting
 $Params = @{

     ResourceGroupName = 'Default-Storage-SouthCentralUS'; # The name of the ARM Resource Group that contains your Azure Automation Account
     AutomationAccountName = 'Automation1'; # The name of the Azure Automation Account where you want a node on-boarded to
     ComputerName = @('testsrv6'); # The names of the computers that the meta configuration will be generated for
     OutputFolder = 'c:\temp';
 }
 # Use PowerShell splatting to pass parameters to the Azure Automation cmdlet being invoked
 # For more info about splatting, run: Get-Help -Name about_Splatting
 Get-AzureRmAutomationDscOnboardingMetaconfig @Params