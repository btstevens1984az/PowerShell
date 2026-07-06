# Purpose: AccountExpireSampleQuest — General-purpose PowerShell utilities.
if (-not (Get-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction SilentlyContinue)) 
{
	Add-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction stop
}
$date10 = (Get-Date).adddays(10)
#OUs to search for soon to be expired accounts
$OUs ="OU=TESTOU,DC=kaylos,DC=lab","OU=TESTOU2,DC=kaylos,DC=lab"

$users = $ous | ForEach-Object {Get-QADUser -AccountExpiresBefore $date10 -SearchRoot $_ -IncludedProperties "manager","accountexpires" }

foreach ($user in $users)
{
	$managerEmail = (get-QADuser $user.manager).mail
	$accountExpireson = $user.AccountExpires
	$subject = "The following user is about to expire:" + $user.DisplayName
	$subject = "$($user.displayname) will expire on $($user.accountexpires)"
	$from = "clientservices@10.56.20.88"
	$smtpserver ="smtp.contoso.com"
	$body  = @"
		"$($user.displayname) will expire on $($user.accountexpires)"
		Please reply to this message if the account expiration needs to be extended.	
"@
	Send-MailMessage -To $managerEmail -Subject $subject -Body $body -from $from -SmtpServer $smtpserver
}
