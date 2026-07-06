# Purpose: ImportStudents — Network diagnostics, DNS, DHCP, and connectivity.

function ConvertNoteToHash
{
	param ($obj)
	$noteProps = Get-Member -InputObject $obj -MemberType "noteproperty"
	$hash = $noteprops | %{@{$_.name=$obj.$($_.name)}}
	$hash
}



function ConvertNoteTo-Hash
{
	[CmdletBinding()]
	param([Parameter(Mandatory=$true,ValueFromPipeline=$true)]$obj)
	process
	{
		$hash = @{}
		$noteProps = Get-Member -InputObject $obj -MemberType "noteproperty"
		foreach ($prop in $noteProps)
		{
			$hashtemp = $prop | %{@{$_.name=$obj.$($_.name)}}
			$hash = $hash + $hashtemp
		}
		$hash
	}	
}
$defaultPassword = read-host "DefaultPassword" –AsSecureString
$groups = "cn=Group1,cn=users,dc=contoso,dc=com","cn=Group2,cn=users,dc=contoso,dc=com”

foreach ($user in $newUsers)
{
$properties = ConvertNoteTo-Hash $user
$properties.remove("sAMAccountName")
New-ADUser -Path "ou=test1,dc=contoso,dc=com" -OtherAttributes $properties -Name $user.sAMAccountName -AccountPassword $defaultPassword -ChangePasswordAtLogon $true -PassThru |
Add-ADPrincipalGroupMembership -memberof $groups -PassThru | Enable-ADAccount
}


Function New-TestADusers
{
	[CmdletBinding()]
	param([Parameter(Mandatory=$true,ValueFromPipeline=$true)][string]$namesuffix)
	Begin
	{
	if (-not (Get-Module ActiveDirectory -ErrorAction SilentlyContinue)) 
		{
			Import-Module ActiveDirectory -ErrorAction stop
		}
	}
	Process
	{
		$prefix="Test"
		New-ADUser -Name "Test$namesuffix" -Surname "TestLastName$namesuffix" -GivenName "TestFirstName$namesuffix" -Department "TestDepartment" -Office "TestOffice" -SamAccountName "Test$namesuffix" -UserPrincipalName "Test$namesuffix@$((get-ADDomain).DNSRoot)"
	}
}