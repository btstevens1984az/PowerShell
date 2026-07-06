Function New-CmbApplication {
<#
.SYNOPSIS 
Creates Applications in SCCM
.DESCRIPTION
This Script creates a Application in SCCM, distributes and then deploys to a set user and device collection, After this is finished it then Emails a confirmation with Basic Verbos step confirmation.

This Script has variables inside that need to be set to your environment. Lines 56, 87 to 92, 179 to 183



.Example 
New-CmbApplication -CmbAppName "test" -CmbAppDescription "test description" -CmbAppPublisher "Test Publisher" -CmbAppVersion "5.0.900" -CmbAppPath "\\165.90.34.63\sccmmedia$\ApplicationMedia\ITIS\Putty069 - Copy\putty-64bit-0.69-installer.msi" -CmbAppCategory Management -Verbose

you can also call this script from an external CSV using import-csv
 $testcsv =@{}
 $testcsv = import-csv "c:\Adminsharearea\testcsv3.csv"
 ForEach ($test in $testcsv) {
    $CmbAppName1 = $test.CmbAppName
    $CmbAppDescription1 = $test.CmbAppDescription
    $CmbAppPublisher1 = $test.CmbAppPublisher
    $CmbAppVersion1 = $test.CmbAppVersion
    $CmbAppPath1 = $test.CmbAppPath
    $CmbAppCategory1 = $test.CmbAppCategory
    new-CmbApplication -CmbAppName "$CmbAppName1" -CmbAppDescription "$CmbAppDescription1" -CmbAppPublisher "$CmbAppPublisher1" -CmbAppVersion "$CmbAppVersion1" -CmbAppPath "$CmbAppPath1" -CmbAppCategory "$CmbAppCategory1" -Verbose
    
    PSVer        :   3.0/4.0/5.0
    SCCM Version :   Tested on SCCM 1702

  }
#>

   [Cmdletbinding()]    
   Param (
    [Parameter(Mandatory=$True, HelpMessage=" Please enter the Name of the application you are publishing")]
    [ValidateNotNullOrEmpty()]
    [String[]] $CmbAppName,
    [Parameter(Mandatory=$True, HelpMessage=" Please enter the Description of the application you are publishing")]
    [ValidateNotNullOrEmpty()]
    [String[]] $CmbAppDescription,
    [Parameter(Mandatory=$True, HelpMessage=" Please enter the Publisher of the application you are publishing")]
    [ValidateNotNullOrEmpty()]
    [String[]] $CmbAppPublisher,
    [Parameter(Mandatory=$true, HelpMessage=" Please enter the Version of the application you are publishing")]
    [ValidateNotNullOrEmpty()]
    [String[]] $CmbAppVersion,
    [Parameter(Mandatory=$True, HelpMessage=" Please enter the path to the application you are publishing - Example \\241.169.50.19\sccmmedia$\folder\application.msi")]
    [ValidateNotNullOrEmpty()]
    [String[]] $CmbAppPath,
    [Parameter(Mandatory=$True, Helpmessage=" Please enter the Catergory to note against the application you are publishing.")]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("Management","TAS Team")]  #Add your Categories here or hash out the line to unrestrict
    [String[]] $CmbAppCategory





            ) #End of Param
    
    Begin {
          
        Import-Module -Name "$(split-path $Env:SMS_ADMIN_UI_PATH)\ConfigurationManager.psd1"
        Set-Location -Path UOR:
        $CmbBody2 = ". `n `n"  
        $CmbBody2 +=". `n `n" 
        $CmbBody2 +=". `n `n"
        $CmbBody2 +=". `n `n"
        $CmbBody2 +=". `n `n" 
        $CmbBody2 += "Start of Logging for creating $CmbAppName in sccm `n"
 
        # Variables -  if wanting to hard encode settings remove the hash and # the parameter below and # param above. 

        #$CmbAppName = ""
        #$CmbAppDescription = ""
        #$CmbAppPublisher = ""
        #$CmbAppVersion = ""
        #$CmbAppPath = ""
        #$CmbAppCategory = ""  



        $CmbDistributionGroupName = "Group Name here - this must exist"
        $CmbDistributionPointName =  "Distribution point name here"
        $CmbDistributionPointName2 = "Distribution point name here"
        $CmbDistributionPointName3 = "Distribution point name here"
        $CmbUserDesploymentGroupName = "User group name here. i have a test group that i am also a member so i can check application centre immediately" 
        $CmbTestDevice = "Computer used for testing here - i would use my workstation so i can see the applicaiton come available from the software centre immediately"
          
        


    } #End Begin

    Process {

            #Check if Application Category Exists
            
            Write-verbose "Checking If application Category exists"
            $CmbBody2 = "Checking If application Category exists `n"
            $ApplicationCategoryExists = Get-CMCategory -CategoryType AppCategories -Name "$CmbAppCategory"
            If ($ApplicationCategoryExists) {
                Write-verbose "Application Category Exist"
                $CmbBody2 = ". Application Category Exists and was not created `n"
                }

            Else {
                Write-verbose "Application Category doesnt exist, creating now."
                $CmbBody2 += "Application Catergory $CmbAppCategory did not exist and has been created. New-CMcategory `n `n"
                New-CMCategory -CategoryType AppCategories -Name "$CmbAppCategory" -Verbose
            }

            # Checking for Application existing, if doesnt exist creates a new application. 
           
            Write-verbose "Checking if application $CmbAppName exists”
            $CmbBody2 += "Checking if application $CmbAppName exists 'n `n”
            # Check if the application exists
            $ApplicationNameExist =  Get-CMApplication -Name "$CmbAppName" -Verbose
            If ($ApplicationNameExist) {
                Write-verbose "The attempted creation of application $CmbAppName has stopped since this application already exists in SCCM. "
                $CmbBody2 += ". The attempted creation of application $CmbAppName has stopped since this application already exists in SCCM. `n `n"
                Exit
            }

            Else {
                Write-verbose "The Application $CmbAppName does not exist - Powershell now creating Application" 
                $CmbBody2 += ". Application does not exist - PowerShell now creating Application `n"
                New-CMApplication -Name "$CmbAppName" -Description "$CmbAppDescription" -Publisher "$CmbAppPublisher" -SoftwareVersion "$CmbAppVersion" -AutoInstall $true 
                Set-CMApplication -Name "$CmbAppName"  -LocalizedApplicationName "$CmbAppName"  -LocalizedApplicationDescription "$CmbAppDescription" -AppCategories "$CmbAppCategory" -SendToProtectedDistributionPoint $true 
               
                #Add the Deployment type automatically from the MSI 
               
                Add-CMDeploymentType -ApplicationName "$CmbAppName" -InstallationFileLocation "$CmbAppPath" -MsiInstaller -AutoIdentifyFromInstallationFile -ForceForUnknownPublisher $true -InstallationBehaviorType InstallForSystem
                Write-verbose " Distribute the Content to the DP Group and Distribution Points "
                $CmbBody2 += ". $CmbAppName has being created and is being distributed to $CmbDistributionPointName,$CmbDistributionPointName2,$CmbDistributionPointName3 and $CmbDistributionGroupName 'n 'n"
                Start-CMContentDistribution -ApplicationName "$CmbAppName" -DistributionPointName "$CmbDistributionPointName" #-Verbose
                Start-CMContentDistribution -ApplicationName "$CmbAppName" -DistributionPointName "$CmbDistributionPointName2" #-Verbose
                Start-CMContentDistribution -ApplicationName "$CmbAppName" -DistributionPointName "$CmbDistributionPointName3" #-Verbose
                Start-CMContentDistribution -ApplicationName "$CmbAppName" -DistributionPointGroupName "$CmbDistributionGroupName" #-Verbose
                Write-verbose " Creating Device Collection for application $CmbAppName "
                $CmbBody2 += ". Creating Device Collection for application $CmbAppName         `n"
                New-CMDeviceCollection -Name "$CmbAppName" -Comment "All the Machines where $CmbAppName is sent to" -LimitingCollectionName "All Systems"  -RefreshType Periodic -RefreshSchedule (New-CMSchedule -Start (get-date) -RecurInterval Days -RecurCount 7) 
                Write-verbose "Add the Direct Membership Rule to add a Resource as a member to the Collection"
                $CmbBody2 += ". Adding the direct Membership Rule to $CmbAppName and adding Computer $CmbTestDevice to the collection `n"
                Add-CMDeviceCollectionDirectMembershipRule -CollectionName "$CmbAppName"  -Resource (Get-CMDevice -Name "$CmbTestDevice") #-Verbose
                Write-verbose "Starting the Deployments for the $CmbAppName device collection and the deployment for $CmbUserDesploymentGroupName"
                $cmdbody2 = ". Starting the Deployments for the $CmbAppName device collection and the deployment for $CmbUserDesploymentGroupName. Both deployments are set as available.`n"
               
                # Below are the commands that were planned depreciation. 
                
                Start-CMApplicationDeployment -CollectionName "$CmbAppName" -Name "$CmbAppName" -DeployAction Install -DeployPurpose Available -UserNotification DisplayAll #-AvaliableDate (get-date) -AvaliableTime (get-date) -TimeBaseOn LocalTime  -RebootOutsideServiceWindow $True -Verbose 
                Start-CMApplicationDeployment -CollectionName "$CmbUserDesploymentGroupName" -Name "$CmbAppName" -DeployAction Install -DeployPurpose Available -UserNotification DisplayAll #-AvaliableDate (get-date) -AvaliableTime (get-date) -TimeBaseOn LocalTime -RebootOutsideServiceWindow $True -Verbose 
                
                #New-CMApplicationDeployment -Name "$CmbAppName" -CollectionName "$CmbAppName" -DeployAction Install -DeployPurpose Available -UserNotification DisplayAll -ApprovalRequired # these were not tested
                #New-CMApplicationDeployment -Name -ApprovalRequired -DeployAction Install -DeployPurpose Available -OverrideServiceWindow $false -RebootOutsideServiceWindow $false         # these were not tested
                
                Write-verbose "refresh the Machine Policy on the Members of the Collection"
                $CmbBody2 += ". The Machine Policy has been requested to refresh for members of the Collection $CmbAppName `n"
                Invoke-CMClientNotification -DeviceCollectionName "$CmbAppName" -NotificationType RequestMachinePolicyNow #-Verbose
                Write-verbose "Run the Deployment Summarization"
                $CmbBody2 += ". Running the deployment Summarization `n"
                Invoke-CMDeploymentSummarization -CollectionName "$CmbAppName" #-Verbose
                Write-verbose "$CmbAppName has being created and distributed" 
                $CmbBody2 += ".  `n"
                $CmbBody2 += ". The application $CmbAppName has been created and deployed. End of Script log....  `n"


            }
        }
   
    End{

        # This configures and sends an email of all the application with Verbos log.  

        $CmbFrom = "Powershell@Powershell.is.king"
        $CmbTo = " who@ever.you.want.email.that.this.is.done "
        $CmbCC = "who@ever.else.you.want.to.email" 
        $CmbSubject = "New Application, $CmbAppName has being published." 
        $SmtpServer = "111.111.1111.111"

        $CmbBody1 = "Dear $CmbTo `n `n" 
        $CmbBody1 += "The application $CmbAppName has been published in SCCM Application Centre. `n"
        $CmbBody1 += "This is deployed as Available to the user group $CmbUserDesploymentGroupName `n"
        $CmbBody1 += "and available to the device group $CmbAppName. `n `n"
        $CmbBody1 += "The Application $CmbAppName has the category $CmbAppCategory and has been distributed `n"
        $CmbBody1 += "to the Distribution server group $CmbDistributionGroupName. `n `n"   
        $CmbBody1 += "Once tested please notify the SCCM Admin to have full deployment to required computers/users completed. `n `n" 
        $CmbBody1 += "Love from, `n Powershell `n" 

        $CmbBody = "$CmbBody1$CmbBody2"

        Send-MailMessage -From $CmbFrom -To $CmbTo -Bcc $CmbCC -Subject $CmbSubject -Body $CmbBody -SmtpServer $SmtpServer -Verbose 

    }

}      