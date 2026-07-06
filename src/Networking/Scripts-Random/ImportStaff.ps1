# Purpose: ImportStaff — Network diagnostics, DNS, DHCP, and connectivity.
#ImportStaff.ps1

#import students script
param($inputFile="users.csv")
$DefaultOu ="ou=NewUsers,dc=sbdom,dc=sbcusd"
$domSuffix = "sbdom.sbcusd"
$failures = @()
$modified = @()
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

if (-not (Get-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction SilentlyContinue)) 
{
	Write-Host "Attempting to load Quest Active Roles cmdlets..."
	Add-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction stop
	Write-Host "Quest Active Roles cmdlets loaded successfully."
}

#todo add test-path on $inputFile
$users = Import-Csv $inputFile

Function GetUserbyEmpID
#Returns User object if there was a match on the employeeid
#Will check for matches with or without padded zeros for a 8 digit ID
#Employee ids are stored as strings in Active Directory.
{
	param([string]$ID)
	$user = Get-QADUser -ObjectAttributes @{"employeeid"=[int]$id}
	If(!$user)
	{#Check for user incase numbers are padded to the left by 0000s
		$user = Get-QADUser -ObjectAttributes @{"employeeid"=$($id.padleft(8,"0"))}
	}
	If($user)
	{$user}
	Else
	{$user=$null}
}
Function TrimName
{ param([string]$username)
	if ($username.length -ge 20)
	{
		$username = $username.substring(0,20)
		$username
	}
	else
	{$username}
}


Function GenStaffAccountName
{	param ($FN,$MN=$null,$LN)
	$FN=$FN.trim()
	If($MN){$MN=$MN.trim()}
	$LN=$LN.trim()
	$username = "$FN$LN"
	$username = TrimName $username
	$testuser = Get-QADUser -SamAccountName $username -IncludedProperties "Employeeid"
	If (!($testuser))
	{$username}
	elseif($testuser -and !($testuser.employeeid))
	{#modify user by importing employeeid
		$testuser | Set-QADUser -ObjectAttributes @{Employeeid="$($user.id)"} | Out-Null
		"Modified"
	}
	else
	{
		if($MN -or $mn.length -gt 0)
		{
		$username = $fn+$mn.substring(0,1)+$LN
		$username = TrimName $username
		}
			If (!(Get-QADUser -SamAccountName $username))
			{$username}
			else
			{
			$i=1
				do{
				$username = $fn+$mn.substring(0,1)+$LN+$i
				$i++	
				}while((Get-QADUser -SamAccountName $username)-and $i -le 10)
				If(Get-QADUser -SamAccountName $username)
				{
				
				$null
				throw("Duplicate username found $username, could not generate a new username since more than 10 duplicates exist")
				}
				else
				{
				$username
				}
			}
	}
}
Function QuickNew
{#Script is dependent on outside variables and is only used for testing purposes
#this can be removed from the production script
Param ($name)
New-QADUser -Name $name -SamAccountName $name -UserPrincipalName "$name@$domSuffix" -ParentContainer $DefaultOu
}

Function CreateStaff
{param ($user)
	#check if user already exists
	trap{
	Write-Host "unexpected error on:"
	Write-Host $user
	$user >>"Staffimporterrors.txt"
	$Failures = $Failures + $user
	$Error >>"Staffimporterrors.txt"
	$Error
	$Error.Clear()
	continue
	}
	If (GetUserbyEmpID $user.id)
	{
		Write-Host "$($user.id) already exists, moving on to next user"
		continue
	}
	
	
	$newName = GenStaffAccountName $user.FName $user.Mname $user.LName 
	If ($newName -eq "Modified")
	{
	$user >> "modified.txt"
	}
	elseIf ($newName)
	{
		$displayname= "$($user.lname), $($user.fname)"	
		#This is where user is created
		#Edit here for additional properties
		$tempuser = New-QADUser -Name $newName -SamAccountName $newName -Department $user.orgDesc -office $user.OrgDesc -FirstName $user.FName -LastName $user.LName `
		-title $user.JobDeslong -UserPrincipalName "$newname@$domSuffix" -ParentContainer $DefaultOu -ObjectAttributes @{Middlename=$user.Mname;EmployeeID=$user.ID}`
		-DisplayName $displayname -UserPassword $user.id 
		$tempuser | Disable-QADUser
	
	}
	

}
Foreach ($user in $Users)
{
	CreateStaff $user
}
$Failures | Export-Csv "stafffailures.csv" -NoTypeInformation
#$modified | Export-Csv "Straffmodifed.csv" -Notypeinformation	