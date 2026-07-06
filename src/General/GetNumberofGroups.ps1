# Purpose: GetNumberofGroups — General-purpose PowerShell utilities.
Function Get-NumberofGroups
{
	process
	{
		$numberOfGroups = Get-ADgroup -SearchBase (Get-ADDomain).DistinguishedName `
		-Filter {member -recursivematch $_.DistinguishedName} |
		Measure-object
		Add-Member -inputobject	 $_ -MemberType noteproperty -name "NumberOfGroups" -value $numberOfGroups.count -Force
		$_
	}
}

$users = get-aduser -filter * | Get-NumberofGroups
$topUsers = $users | Sort-Object NumberOfGroups -Descending | select-object -First 10
$topusers | Out-GridView