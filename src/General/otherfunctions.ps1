# Purpose: otherfunctions — General-purpose PowerShell utilities.
#functions
Function Get-WMIProperties
{
process
{

}

}

Function VerifyDN
{
	param([string]$DN=$(throw "Distinguished Name required"))
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

	if (get-qadobject $DN)
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
	if ($_)
	{
	[int]$days = ((Get-Date) - $_.lastlogontimestamp).TotalDays
	$_ | Add-Member -MemberType NoteProperty -Name "DaysStale" -Value $days -PassThru
	}
	elseif($objComputer)
	{[int]$days = ((Get-Date) - $objComputer.lastlogontimestamp).TotalDays
	$objComputer | Add-Member -MemberType NoteProperty -Name "DaysStale" -Value $days
	$objComputer
	}
	}
}


Function GetDaysSinceLastLogonTime
{
param($computerName)
$computer = Get-QADComputer -IncludedProperties "LastLogonTimeStamp"
[int]$days = ((Get-Date) - $computer.lastlogontimestamp).TotalDays
$days
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

#Get-LocalMembership.ps1

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

#sample usage:
#  Get-LocalMembership -group "Administrators"
#  Get-LocalMembership -computer localhost -group "Administrators"
