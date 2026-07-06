# Purpose: server-diskspace — Storage management and disk operations.
$erroractionpreference = "SilentlyContinue"
$objComputers = gc C:\AdminTasks\ScriptsPS\ComputerList\servers.txt
$smtpServer = "86.202.42.242" 
$smtp = New-Object Net.Mail.SmtpClient($smtpServer) 
$emailFrom = "Power@example.com" 
$emailTo = "kkreitin@example.com" 

foreach ($Computer in $objComputers)

{
	if (gwmi Win32_LogicalDisk -filter drivetype=3 -computer $Computer | ? {$_.freespace/1mb -lt 100000}) 

{
	    $objDisk = gwmi Win32_LogicalDisk -filter drivetype=3 -computer $Computer
		$subject = "Free Space on:", $Computer 
		$body = "From Server-DiskSpace.ps1 : Computer Name:", $Computer, "-", "Total Size:", ($objDisk.size/1mb), "-", "Free Space:", ($objDisk.Freespace/1mb)
		$smtp.Send($emailFrom,$emailTo,$subject,$body)
			
}
	else
{
			Write-Host "Nothing to report for" $Computer
}
}
	
Write-Host " "
Write-Host "Computer Name:" ($Computer)
Write-Host "Total Size:" ($objDisk.size/1mb)
Write-Host "Free Space:" ($objDisk.Freespace/1mb)





