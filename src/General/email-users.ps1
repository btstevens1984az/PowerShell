# Purpose: email-users — General-purpose PowerShell utilities.
$erroractionpreference = "SilentlyContinue"
$objUsers = import-csv H:\AD-Reports\user.csv
$smtpServer = "86.202.42.242" 
$smtp = New-Object Net.Mail.SmtpClient($smtpServer) 
$emailFrom = "PowerShell.KK@example.com" 
$emailTo = "1@68.60.77.68" 

foreach ($User in $objUsers) get-qaduser

{
		$emailTo = $_.email
	    $PasswordLastSet = "About 125 Million Years AGO!"
		$subject = "Notice for Password Last Changed Date :"
		$body = "From Network Team : User Name:", $user, "-", "Days Since Last Changed:", ($PasswordlastSet)
		$smtp.Send($emailFrom,$emailTo,$subject,$body)
			
}
	
Write-Host "EMAILED " $user






