<# 
 .SYNOPSIS 
     Create a set of 5 collections in Configuration Manager to manage the applications you are metering:
 
 .DESCRIPTION 
     Collections created:
        - Where application is installed
        - Where application has been used in the last XXX days
        - Where application is in the warning zone
        - Where application has been used over XXX days
        - Where there is no last usage
    You can set the schedule of update of the collection (in days, default is 7),the software (It should be associated to a software metering rule), the period of usage (in days), and a prefix for the name of the collections.
    If you dont add a prefix the naming of the collection will be: Soft-Installed
    If you add a prefix, the naming will be: Metering-Soft-Installed

    After the creation of these collections you will be able to deploy an uninstallation of the software on the 4th collection

    The software inventory and the software metering should be activated

    For more information have a look on the excellent blog post from Nicolas Pilon: https://www.systemcenterdudes.com/sccm-automatically-uninstall-application/
 
 .PARAMETER SiteServer
    Your site server name. Mandatory

 .PARAMETER SiteCode
    Your site code. Mandatory

 .PARAMETER software
    The application that you are metering. Mandatory

 .PARAMETER Usage
    The number of days you want to set for the usage. Optional, default is 90

 .PARAMETER Schedule
    The schedule of update of your collections in days. Optional, default is 7

 .PARAMETER Prefix
    Can be usefull if you have a naming convention for your collections

     Website: http://microsoft-desktop.com/
     Twitter: @gbouchu
     Idea is borned after reading https://www.systemcenterdudes.com/sccm-automatically-uninstall-application/

 .EXAMPLE 
     CreatecollRules -Siteserver SCCM01 -Sitecode LAB -Software Photoshop -usage 90 -schedule 4 -prefix SoftMet
     CreatecollRules -Siteserver SCCM01 -Sitecode LAB -Software Word

  #>


Param(
        [Parameter(Mandatory=$True,HelpMessage="Please Enter Primary Server Site Server")]
            $SiteServer,
        [Parameter(Mandatory=$True,HelpMessage="Please Enter Primary Server Site code")]
            $SiteCode,
        [Parameter(Mandatory=$True,HelpMessage="Please Enter the software you want to inventory")]
            $software,
        [Parameter(Mandatory=$false)]
            $usage,
        [Parameter(Mandatory=$false)]
            $schedule,
        [Parameter(Mandatory=$false)]
            $Prefix
        )


    Function Create-Collection
	{
		[CmdLetBinding()]
		Param (
			[Parameter(Mandatory = $True)]
			[String]$collname,
			[Parameter(Mandatory = $True)]
			[String]$siteServer,
			[Parameter(Mandatory = $True)]
			[String]$sitecode,
            [Parameter(Mandatory = $True)]
			[String]$LimitID,
            [Parameter(Mandatory = $True)]
			[String]$Sched
		)
		
		$queryname = $collname
		
		#Create collection
		$CMCollection = ([WMIClass]"\\$($siteserver)\root\sms\site_$($SiteCode):SMS_Collection").CreateInstance()
		$CMCollection.Name = $collname
		$CMCollection.Comment = "Created by PowerShell script !"
		$CMCollection.LimitToCollectionID = $LimitID
		$CMCollection.RefreshType = 2
		$CMCollection.Put()

		#Create Schedule
		$CMSchedule = ([WMIClass]"\\$($siteserver)\Root\sms\site_$($SiteCode):SMS_ST_RecurInterval").CreateInstance()
		$CMSchedule.DaySpan = $Sched
		$CMSchedule.StartTime = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-Date).ToString())
		$CMCollection.RefreshSchedule = $CMSchedule
		$CMCollection.Put()
	}

    Function Add-CollectionQueryRule
    {
        [CmdletBinding()]
        Param(
             [Parameter(Mandatory=$True)]
                    $SiteServer,
             [Parameter(Mandatory=$True)]
                    $SiteCode,
             [Parameter(Mandatory=$True)]
                    $CollectionName,
             [Parameter(Mandatory=$True)]
                    $QueryExpression,
             [Parameter(Mandatory=$True)]
                    $Queryname                
             )

        $Collection = Get-WmiObject -Namespace "Root\SMS\Site_$SiteCode" -Class SMS_Collection -ComputerName $SiteServer -Filter "Name='$CollectionName' and CollectionType = '2'"


        #Validate Query syntax  
        $ValidateQuery = Invoke-WmiMethod -Namespace "Root\SMS\site_$SiteCode" -Class SMS_CollectionRuleQuery -Name ValidateQuery -ArgumentList $QueryExpression -ComputerName $SiteServer
 
        If($ValidateQuery){
            #Read Lazy properties
            $Collection.Get()
        
            #Create new rule
            $NewRule = ([WMIClass]"\\$SiteServer\Root\SMS\Site_$($SiteCode):SMS_CollectionRuleQuery").CreateInstance()
            $NewRule.QueryExpression = $QueryExpression
            $NewRule.RuleName = $Queryname
 
            #Commit changes and initiate the collection evaluator                       
            $Collection.CollectionRules += $NewRule.psobject.baseobject
            $Collection.Put()
            $Collection.RequestRefresh()


        }         
    }

    Function Add-CollectionExcludeRule
    {
    [CmdletBinding()]
    Param(
         [Parameter(Mandatory=$True,HelpMessage="Please Enter Primary Server Site Server")]
                $SiteServer,
         [Parameter(Mandatory=$True,HelpMessage="Please Enter Primary Server Site code")]
                $SiteCode,
         [Parameter(Mandatory=$True,HelpMessage="Please Enter collection name where do you want to set new rule")]
                $CollectionName,
         [Parameter(Mandatory=$True,HelpMessage="Please Enter collection name that you want to exclude")]
                $ExCollectionName 
         )
 
    $ParentCollection = Get-WmiObject -Namespace "root\sms\Site_$SiteCode" -Class SMS_Collection -ComputerName $SiteServer -Filter "Name='$CollectionName'"
    $SubCollection = Get-WmiObject -Namespace "root\sms\Site_$SiteCode" -Class SMS_Collection -ComputerName $SiteServer -Filter "Name='$ExCollectionName'"
 
    $VerifyDependency = Invoke-WmiMethod -Namespace "root\sms\Site_$SiteCode" -Class SMS_Collection -Name VerifyNoCircularDependencies -ArgumentList @($ParentCollection.__PATH,$SubCollection.__PATH,$null) -ComputerName $SiteServer 
 
    If($VerifyDependency){
        #Read Lazy properties
        $ParentCollection.Get()
        
        #Create new rule
        $NewRule = ([WMIClass]"\\$SiteServer\root\SMS\Site_$($SiteCode):SMS_CollectionRuleExcludeCollection").CreateInstance()
        $NewRule.ExcludeCollectionID = $SubCollection.CollectionID
        $NewRule.RuleName = $SubCollection.Name
        
        #Commit changes and initiate the collection evaluator                      
        $ParentCollection.CollectionRules += $NewRule.psobject.baseobject
        $ParentCollection.Put()
        $ParentCollection.RequestRefresh()
        }                
    }

    Function Add-CollectionIncludeRule
    {
        [CmdletBinding()]
        Param(
             [Parameter(Mandatory=$True)]
                    $SiteServer,
             [Parameter(Mandatory=$True)]
                    $SiteCode,
             [Parameter(Mandatory=$True)]
                    $CollectionName,
             [Parameter(Mandatory=$True)]
                    $IncCollectionName 
             )
 
        $ParentCollection = Get-WmiObject -Namespace "Root\sms\Site_$SiteCode" -Class SMS_Collection -ComputerName $SiteServer -Filter "Name='$CollectionName'"
        $SubCollection = Get-WmiObject -Namespace "Root\sms\Site_$SiteCode" -Class SMS_Collection -ComputerName $SiteServer -Filter "Name='$IncCollectionName'"
 
        $VerifyDependency = Invoke-WmiMethod -Namespace "Root\sms\Site_$SiteCode" -Class SMS_Collection -Name VerifyNoCircularDependencies -ArgumentList @($ParentCollection.__PATH,$SubCollection.__PATH,$null) -ComputerName $SiteServer
 
        If($VerifyDependency)
        {
            #Read Lazy properties
            $ParentCollection.Get()
        
            #Create new rule
            $NewRule = ([WMIClass]"\\$SiteServer\root\SMS\Site_$($SiteCode):SMS_CollectionRuleIncludeCollection").CreateInstance()
            $NewRule.IncludeCollectionID = $SubCollection.CollectionID
            $NewRule.RuleName = $SubCollection.Name
        
            #Commit changes and initiate the collection evaluator                        
            $ParentCollection.CollectionRules += $NewRule.psobject.baseobject
            $ParentCollection.Put()
            $ParentCollection.RequestRefresh()
        }        
         
    }

    if ($usage -eq $null)
    {
        $usage = 90
    }

    if ($schedule -eq $null)
    {
        $schedule = 7
    }

    Write-Host $sofware

    $ScriptName = "Collections for Software metering"

    # Naming collection
    $collname1 = "$prefix$software-Installed"
    $collname2 = "$prefix$software-Last usage in last $usage days"
    $collname3 = "$prefix$software-Warning zone"                      #Include coll1 - Exclude coll2
    $collname4 = "$prefix$software-Last usage over $usage days"
    $collname5 = "$prefix$software-No last usage"                     #Include coll3 - Exclude coll4
    
    # Query rule
    $queryrule1 = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_INSTALLED_SOFTWARE on SMS_G_System_INSTALLED_SOFTWARE.ResourceId = SMS_R_System.ResourceId where SMS_G_System_INSTALLED_SOFTWARE.ProductName like '%$software%'"
    $queryrule2 = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_SYSTEM  inner join SMS_MonthlyUsageSummary on SMS_R_SYSTEM.ResourceID = SMS_MonthlyUsageSummary.ResourceID INNER JOIN SMS_MeteredFiles ON SMS_MonthlyUsageSummary.FileID = SMS_MeteredFile.MeteredFileID WHERE SMS_MeteredFiles.ProductName like '%$software%' AND DateDiff(day, SMS_MonthlyUsageSummary.LastUsage, GetDate()) < $usage"
    $queryrule4 = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_SYSTEM  inner join SMS_MonthlyUsageSummary on SMS_R_SYSTEM.ResourceID = SMS_MonthlyUsageSummary.ResourceID INNER JOIN SMS_MeteredFiles ON SMS_MonthlyUsageSummary.FileID = SMS_MeteredFile.MeteredFileID WHERE SMS_MeteredFiles.ProductName like '%$software%' AND SMS_MonthlyUsageSummary.LastUsage IS NOT NULL"

    # Collection creation
    $exist = Get-WmiObject -Class sms_collection -Namespace root\sms\site_$($SiteCode) -ComputerName $SiteServer -filter "Name = '$collname1'" | Select-object CollectionID, Name

    if ($exist -ne $null)
	{
		[Windows.Forms.MessageBox]::Show('The collection ' + $collname1 + ' already exists and will not be created !', $ScriptName, [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information) | Out-Null
	}
    else
    {
        Create-Collection -collname $collname1 -siteServer $SiteServer -sitecode $SiteCode -LimitID "44.43.150.203" -Sched $schedule

        # Get the coll ID to set is a limit coll
        $SelColl = Get-WmiObject -ComputerName $SiteServer -Namespace "root\sms\site_$($SiteCode)" -Class sms_collection -Filter "Name = '$Collname1'"
        $CollID1 = $SelColl.CollectionID
        
        Create-Collection -collname $collname2 -siteServer $SiteServer -sitecode $SiteCode -LimitID $CollID1 -Sched $schedule
        Create-Collection -collname $collname3 -siteServer $SiteServer -sitecode $SiteCode -LimitID $CollID1 -Sched $schedule
    
        # Get the coll ID to set is a limit coll
        $SelColl = Get-WmiObject -ComputerName $SiteServer -Namespace "root\sms\site_$($SiteCode)" -Class sms_collection -Filter "Name = '$Collname3'"
        $CollID3 = $SelColl.CollectionID

        Create-Collection -collname $collname4 -siteServer $SiteServer -sitecode $SiteCode -LimitID $CollID3 -Sched $schedule
        Create-Collection -collname $collname5 -siteServer $SiteServer -sitecode $SiteCode -LimitID $CollID3 -Sched $schedule


        Add-CollectionQueryRule -SiteServer $siteserver -SiteCode $sitecode -CollectionName $collname1 -QueryExpression $queryrule1 -Queryname $collname1
        Add-CollectionQueryRule -SiteServer $siteserver -SiteCode $sitecode -CollectionName $collname2 -QueryExpression $queryrule2 -Queryname $collname2
        Add-CollectionQueryRule -SiteServer $siteserver -SiteCode $sitecode -CollectionName $collname4 -QueryExpression $queryrule4 -Queryname $collname4

        Add-CollectionIncludeRule -SiteServer $siteserver -SiteCode $sitecode -CollectionName $collname3 -IncCollectionName $collname1
        Add-CollectionIncludeRule -SiteServer $siteserver -SiteCode $sitecode -CollectionName $collname5 -IncCollectionName $collname3

        Add-CollectionExcludeRule -SiteServer $siteserver -SiteCode $sitecode -CollectionName $collname3 -ExCollectionName $collname2
        Add-CollectionExcludeRule -SiteServer $siteserver -SiteCode $sitecode -CollectionName $collname5 -ExCollectionName $collname4
    }