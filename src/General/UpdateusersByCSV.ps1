# Purpose: UpdateusersByCSV — General-purpose PowerShell utilities.
$CsvPath = "h:\powershell\updateUsers.csv"
$Errlog = "h:\powershell\errorlog.txt"
$unabletoupdate = "h:\Powershell\unabletoupdate.txt"

if (-not (Get-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction SilentlyContinue)) 
{
	Add-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction stop
}
$Csv = Import-Csv $CsvPath
#$props= $props = $csv | gm  -MemberType note* | %{$_.name}
Foreach ($Entry in $csv)
{
	trap 
	{
		Write-Host "Error encounters on $($entry.samaccountname), skipping user".
		$Entry.sAMAccountName >>$Errlog
		$Error >> $Errlog
		$Error.Clear()
		continue
		
	}
	
	$user = Get-QADUser -saMAccountName $entry.saMAccountname
	If ($user.samAccountName -and $entry.manager )
	{
#	$user | Set-QADUser -Department $entry.Department -FirstName $entry.GivenName -City $entry.l `
#	-PostalCode $entry.postalcode -LastName $entry.SN -StateOrProvince $entry.ST `
#	-StreetAddress $entry.Street -PhoneNumber $Entry.telephoneNumber -Title $entry.title `
#	-ObjectAttributes @{co="$($entry.co)";ipphone=$($Entry.ipphone)}
	
	$user | Set-QADUser -Department $entry.Department -FirstName $entry.GivenName -City $entry.l `
	-Manager $entry.manager -PostalCode $entry.postalcode -LastName $entry.SN -StateOrProvince $entry.ST `
	-StreetAddress $entry.Street -PhoneNumber $Entry.telephoneNumber -Title $entry.title `
	-ObjectAttributes @{co="$($entry.co)";ipphone=$($Entry.ipphone);extensionAttribute2="$($entry.extensionAttribute2)"} -whatif
	}
	Elseif($user.samAccountName)
	{
		$user | Set-QADUser -Department $entry.Department -FirstName $entry.GivenName -City $entry.l `
	-PostalCode $entry.postalcode -LastName $entry.SN -StateOrProvince $entry.ST `
	-StreetAddress $entry.Street -PhoneNumber $Entry.telephoneNumber -Title $entry.title `
	-ObjectAttributes @{co="$($entry.co)";ipphone=$($Entry.ipphone);extensionAttribute2="$($entry.extensionAttribute2)"} -whatif
	}
	Else
	{
		$entry |  Out-File $unabletoupdate -Append
	}

	$user = $null
}
#The sample scripts are not supported under any Microsoft standard support program or service.
#The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims 
#all implied warranties including, without limitation, any implied warranties of 
#merchantability or of fitness for a particular purpose. The entire risk arising out of the use
#or performance of the sample scripts and documentation remains with you. 
#In no event shall Microsoft, its authors, or anyone else involved in the creation,
#production, or delivery of the scripts be liable for any damages whatsoever 
#(including, without limitation, damages for loss of business profits, business interruption, 
#loss of business information, or other pecuniary loss) arising out of the use of or inability 
#to use the sample scripts or documentation, even if Microsoft has been advised of the 
#possibility of such damages.
