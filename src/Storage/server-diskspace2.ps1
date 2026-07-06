# Purpose: server-diskspace2 — Storage management and disk operations.
$erroractionpreference = "SilentlyContinue"
$objComputers = gc C:\AdminTasks\ScriptsPS\ComputerList\servers.txt
$smtpServer = "86.202.42.242" 
$smtp = New-Object Net.Mail.SmtpClient($smtpServer) 
$emailFrom = "diskchecker@example.com" 
$emailTo = "kkreitin@example.com" 

foreach ($Computer in $objComputers)

{
	if (gwmi Win32_LogicalDisk -filter drivetype=3 -computer $Computer | ? {$_.freespace/1mb -lt 100000}) 

{
		$col3 = @{Name='Total Size'; Expression={ [Math]::Round(($_.capacity/1mb))}} 
		$col4 = @{Name='Free Space'; Expression={ [Math]::Round(($_.Freespace/1mb))}} 
	    $objDisk = gwmi Win32_LogicalDisk -filter drivetype=3 -computer $Computer
		$subject = "Free Space on:", $Computer 
		$body = "From Server-DiskSpace.ps1 : Computer Name:", $Computer, "-", "Total Size:", $col3, "-", "Free Space" $col4
		$smtp.Send($emailFrom,$emailTo,$subject,$body)
		
		Write-Host " "
Write-Host $Computer
Write-Host "Total Size:" ($col3)

Write-Host "Free Space:" ($col4)
			
}
	else
{
			Write-Host "Nothing to report for" $Computer
}
}





