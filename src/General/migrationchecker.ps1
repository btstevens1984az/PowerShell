# Purpose: migrationchecker — General-purpose PowerShell utilities.
#migrationChecker.ps1
#version: 0.2
#Create on:7/16/2009
#Last Updated:7/17/2009
#The purpose of this script is to check computers for Active Directory
#migration readiness.
# The script has functionality to reboot target computers and move them to the correct OU 
# using the -reboot and -move switches respectively.
#The only required parameter is the -ou switch which for examples would look like this
# .\migrationchecker.ps1 -ou "ou=department,dc=contoso,dc=com"
#The -failhotfix will cause computers which are missing the hotfix checked to not be listed in the
#ADMT ready file.

param([string]$computerPath= "Computers.txt",[switch]$reboot,[string]$ou=$(Read-Host "targetOU?"),
	$failurePath = "failures",$sucesspath="successes",[switch]$move,[switch]$failhotfix,
	[string]$hotfixID="KB944043-v3",[string]$CheckForGroup = "MigrationAccess")
#-reboot will reboot computers
#-move will move computers to the -ou path specified
$rebootmsg = "Your computer is being restarted by SBCUSD IT for migration purposes. Please save all of your work now."
Write-Host "Beginning Script processing:$(Get-date)"

Function GetFileDateString
{
	$date = get-date
	$datestring = "$($date.year)$($date.month)$($date.hour)$($date.minute)$($date.second)"
	$datestring
}

Function VerifyDN
#Takes a DN(DistinguishName) Returns Object if found otherwise returns $false if not found
{
	
	param([string]$DN=$(throw "Distinguished Name required"))
	trap
	{
	$errortext = @"
	Unable to load Quest Active Roles Powershell cmdlets. Please make sure they are installed.
	The cmdlets can be downloaded from http://www.quest.com/powershell/activeroles-server.aspx
"@
	
	write-host $errortext
	#continue
	break
	
	}
	
	if (-not (Get-PSSnapin Quest.ActiveRoles.ADManagement2 -ErrorAction SilentlyContinue)) 
	{
		Write-Host "Attempting to load Quest Active Roles cmdlets..."
		Add-PSSnapin Quest.ActiveRoles.ADManagement2 -ErrorAction stop
		Write-Host "Quest Active Roles cmdlets loaded successfully."
	}
	$result = get-qadobject $DN
	if ($result)
	{
		$result
	}
	else
	{
		$false
	}
}
$objOU = verifyDN $ou
If ($objOU -eq $false)
{
#Ou specified is not correct
$errMsg = @"
$ou could not be found. Please try again using the following format:
./migrationchecker.ps1 -ou "ou=HR,dc=contoso,dc=com"
Terminiating script now
"@
exit
}
else
{
$strOUName = $objOU.name

}
	
#$computers = "localhost","badhost"
$computers = Get-Content $computerPath
$Failures = @()
$Successes = @()



Function PingComputer
{
	#If status code is 0 then the ping is successful
	param($comp=$(Throw "Must specify an address to ping"))
	$status = $false
	$numTries = 1
	Do
	{$result = Get-WmiObject Win32_pingstatus -Filter "address ='$comp'"
	 $status=$result.statuscode
	 $numTries++
	}until ($status -eq 0 -or $numTries -gt 2)
	$status #return status code
}
Function Get-LocalGroupMembership {
    Param([string]$user=$(Throw "You must enter a user name"),
          [string]$computer=$env:computername
    )
    
    [ADSI]$LocalUser="WinNT://$computer/$Name,user"
    
    $groups=$Localuser.psbase.invoke("Groups") | ForEach-Object {
     $_.GetType().InvokeMember("Name", 'GetProperty', `
     $null, $_, $null)
    }
    
    write $groups        
}
Function Get-LocalMembership {
    Param([string]$group=$(Throw "You must enter a group name."),
          [string]$computer=$env:computername
          )

    [ADSI]$LocalGroup="WinNT://$computer/$group,group"

    $LocalGroup.psbase.invoke("Members") | ForEach-Object {
    
    #get ADS Path of member
    $ADSPath=$_.GetType().InvokeMember("ADSPath", 'GetProperty', `
    $null, $_, $null)
    
    #get the member class, ie user or group
    $class=$_.GetType().InvokeMember("Class", 'GetProperty', `
    $null, $_, $null)
    
    #Get the name property
    $name=$_.GetType().InvokeMember("Name", 'GetProperty', `
    $null, $_, $null)
    
    #Domain members will have an ADSPath like 
    #WinNT://MYDomain/Domain Users.  Local accounts will have
    #be like WinNT://MYDomain/Computername/Administrator

    $domain=$ADSPath.Split("/")[2]

    #if computer name is found between two /, then assume
    #the ADSPath reflects a local object
    if ($ADSPath -match "/$env:computername/") {
        $local=$True
        }
    else {
        $local=$False
       }

    #create a custom object
    $obj = New-Object PSObject
    
    #define custom object properties
    $obj | Add-Member -MemberType NoteProperty -Name "Computer" -Value $computer.toUpper()
    $obj | Add-Member -MemberType NoteProperty -Name "ADSPath" -Value $ADSPath
    $obj | Add-Member -MemberType NoteProperty -Name "Domain" -Value $domain 
    $obj | Add-Member -MemberType NoteProperty -Name "IsLocal" -Value $local 
    $obj | Add-Member -MemberType NoteProperty -Name "Name" -Value $name 
    $obj | Add-Member -MemberType NoteProperty -Name "Class" -Value $class 
         
    #write the result to the pipeline
    write $obj
    }  
}
Function TestWMI
{
#returns true if successful and false if not
param([string]$comp=".")
trap
{
#WMI error
 #$Error.Clear()
 Write-Host $error
 $false
 continue
}
$result = Get-WmiObject -Query "Select caption from Win32_operatingsystem" -ComputerName $comp
	if ($result)
	{
	$true
	}
	else
	{
	$false
	}

}
Function Get-ADCompObj
{
#Initially tested
#pass computername in the pipeline
param($searchroot)
begin
{
	trap
	{
	$errortext = @"
	Unable to load Quest Active Roles Powershell cmdlets. Please make sure they are installed.
	The cmdlets can be downloaded from http://www.quest.com/powershell/activeroles-server.aspx
"@
	
	#write-host $errortext
	#continue
	break
	
	}
	
	if (-not (Get-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction SilentlyContinue)) 
	{
		Write-Host "Attempting to load Quest Active Roles cmdlets..."
		Add-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction stop
		Write-Host "Quest Active Roles cmdlets loaded successfully."
	}

}
process
{
	trap
	{
		Write-Error "Could not fine $_ in Active Directory, skipping"
		continue
	}
	If($searchroot)
	{
	$QADComputer = get-qadcomputer $_ -IncludedProperties "LastLogonTimeStamp" -searchroot $searchroot
	$QADComputer
	
	}
	else
	{
	$QADComputer = get-qadcomputer $_ -IncludedProperties "LastLogonTimeStamp"
	$QADComputer
	}
}
end
{
}
}

Function Add-DaysStale
{
#Tested:make sure to pass object with lastlogontimeStamp Property
param($objComputer)
process
                {
                if ($_.lastlogontimestamp)
                {
                [int]$days = ((Get-Date) - $_.lastlogontimestamp).TotalDays
                $_ | Add-Member -MemberType NoteProperty -Name "DaysStale" -Value $days -PassThru
                }
                elseif($objComputer.lastlogontimestamp)
                {[int]$days = ((Get-Date) - $objComputer.lastlogontimestamp).TotalDays
                $objComputer | Add-Member -MemberType NoteProperty -Name "DaysStale" -Value $days
                $objComputer
                }
                }
}

Function CheckHotFix
{
	#returns hotfix object if found or nothing if not found
	#hotfixid='KB944043-v3'
	param([string]$computer=".",[string]$hotfixID=$(Throw "Must specify a hotfixID"))
	$WmiResult = Get-WmiObject -class Win32_QuickFixEngineering -Filter "hotfixid='$hotfixid'" -ComputerName $computer
	$WmiResult
}
Function GetDefaultUserName
{
	param($computer=$(Throw "Must specify a computername"))
	$HKLM = 2147483650
	$regKey="SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
	$regValueName ="DefaultUsername"
	$wmireg = [WMICLASS]"\\$computer\root\default:stdregprov"
	$reg = $wmireg.GetStringValue($HKLM,$regKey,$regValueName)
	if ($reg.ReturnValue -eq 0)
	{$reg.sValue}
	else
	{"error retrieving last logged on user"}

}
Function GetWMIInfo($objComputer)
{	
	$currentUser = $null
	$model = $null
	$Manufacturer = $null
	$comp = $objComputer.name
	$WMIComp = Get-WmiObject Win32_Computersystem -ComputerName $comp
	$lastloggedonUser = GetDefaultUserName $comp
	If ($WMIComp.username) {$currentuser = $WMIComp.username}
	If ($WMIComp.Manufacturer) {$Manufacturer = $WMIComp.Manufacturer}
	If ($WMIComp.model) {$Model = $WMIComp.model}	
	$objComputer | Add-Member -MemberType NoteProperty -Name "CurrentUser" -Value $currentUser
	$objComputer | Add-Member -MemberType NoteProperty -Name "LastLogonUser" -Value $lastloggedonUser
	$objComputer | Add-Member -MemberType NoteProperty -Name "Model" -Value $Model
	$objComputer | Add-Member -MemberType NoteProperty -Name "Manufacturer" -Value $Manufacturer
}

Function GetDaysSinceLastLogonTime
{
param($computerName)
	if (-not (Get-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction SilentlyContinue)) 
	{
		Write-Host "Attempting to load Quest Active Roles cmdlets..."
		Add-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction stop
		Write-Host "Quest Active Roles cmdlets loaded successfully."
	}
$computer = Get-QADComputer $computerName -IncludedProperties "LastLogonTimeStamp"
	If ($computer.lastlogontimestamp)
	{
		[int]$days = ((Get-Date) - $computer.lastlogontimestamp).TotalDays
		$days
	}
	Else
	{
	$null
	}
}

$i =0
foreach ($computer in $computers)
{
	trap
	{
	$failedObj = New-object PsObject| Select-Object @{n="name";e={$computer}},@{n="failure";e={"OTHER"}}
	$Failures = $Failures + $failedObj
	$Error.Clear()
	continue
	}
	write-progress -activity "Testing Computers for Migration:" -status "Progress:" -percentcomplete ($i/$computers.count*100)
	$i++
	if ((Pingcomputer $computer) -eq 0)
	{#ping successful
		if ((Testwmi $computer))
		{#ping and WMI connectivity successful continue with main script
		$objComputer = $computer | Get-ADCompObj | Add-DaysStale
		$Hotfix = checkhotfix $computer $hotfixID
			If ($Hotfix)
			{
				$objComputer | Add-Member -MemberType noteproperty	-Name "KB944043-V3" -Value "Passed"
			}
			else
			{
				$objComputer | Add-Member -MemberType noteproperty -Name "KB944043-V3" -Value "Failed"
				$failedObj = New-object PsObject| Select-Object @{n="name";e={$computer}},@{n="failure";e={"PatchMissing"}}
				$Failures = $Failures + $failedObj
				#uncomment below line if you don't want to count unpatched computers in successes
				#continue
			}
			#check OU membership
			if (([string]$objComputer.ParentContainerDN) -match $ou)
			#if (([string]($objComputer.distinguishedname)).contains($ou))
			{#Computer is in the correct OU, possible in a sub OU
				$objComputer | Add-Member -MemberType noteproperty -Name "CorrectOU" -Value "Passed"
			}
			elseif($move)
			{
				$Error.Clear()
			   $objComputer | Move-QADObject -NewParentContainer $ou | Out-Null
			   If ($error)
			   {
			   	$objComputer | Add-Member -MemberType noteproperty -Name "CorrectOU" -Value "Failed"
			   }
			   else
			   {
			   	$objComputer | Add-Member -MemberType noteproperty -Name "CorrectOU" -Value "Moved"
			   }
			}
			else
			{
				$objComputer | Add-Member -MemberType noteproperty -Name "CorrectOU" -Value "Failed"
			}
			
			#Check Local Administrators group
			$AdminMemberTest = $null
			$AdminMemberTest = Get-Localmembership "Administrators" $computer | ?{$_.name -match $CheckForGroup}
			If ($AdminMemberTest)
			{
				$objComputer | Add-Member -MemberType noteproperty -Name "MigrationAccess" -Value "Passed"
			}
			Else
			{
				$objComputer | Add-Member -MemberType noteproperty -Name "MigrationAccess" -Value "Failed"
			}
			
			#get the rest of the WMI properties and add to computer object
			GetWMIInfo($objComputer)
			$Successes = $Successes + $objComputer
		} #end of main success if statement
		else 
		{#wmi error
		 $failedObj = New-object PsObject| Select-Object @{n="name";e={$computer}},@{n="failure";e={"WMI"}}
		 $Failures = $Failures + $failedObj
		}
	
	
	}
	else
	{#ping not successful
		$failedObj = New-object PsObject| Select-Object @{n="name";e={$computer}},@{n="failure";e={"PING"}}
		$Failures = $Failures + $failedObj
	
	}

	
	
}#end of main foreach

#add days stil to failuresto help determine if the account is still active in AD
$Failures = $Failures | %{Add-Member -inputobject $_ -Name "daysStale" -MemberType NoteProperty -Value $(GetDaysSinceLastLogonTime $_.name) -passthru }

#Begin Output Section
$failures |Export-csv "$failurePath$strOuName$(GetFileDateString).csv" -NoTypeInformation
$successes | Select-Object name,KB944043-V3,CorrectOU,MigrationAccess,CurrentUser,LastLogonUser,DaysStale,operatingsystem,operatingsystemservicepack,lastlogontimestamp,DN,ParentContainerDN,Model,Manufacturer |
Export-Csv "$sucesspath$strOuName$(GetFileDateString).csv"	-NoTypeInformation
write-progress -activity "Testing Computers for Migration:" -status "Progress:" -percentcomplete ($i/$computers.count*100)

if ($failhotfix)
{
$ready = $Successes | ?{$_.$("KB944043-V3") -eq "Passed" -and $_.CorrectOU -eq "Passed" -and $_.MigrationAccess -eq "Passed" -and $_.currentuser -eq $null}
}
else
{
$ready = $Successes | ?{$_.CorrectOU -eq "Passed" -and $_.MigrationAccess -eq "Passed" -and $_.currentuser -eq $null}
}
If ($ready)
{
	$ready | %{$_.name}|Out-File "ADMTReady$strOuName$(GetFileDateString).txt"

}

If ($reboot)
{
	Write-Host "Rebooting computers now"
	$successes | %{invoke-expression "shutdown /r /c '$rebootmsg' /t 300 /f /m \\$($_.name)"}
}

Write-Host "Script processing finished:$(get-date)"

