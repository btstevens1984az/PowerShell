# Purpose: Get-DiskSpaceHTMLReport — McAfee ePolicy Orchestrator reporting.


Function Get-DiskSpaceHTMLReport {

<#================================================================================================
Edit these with your preferences in the section following this one:
	$ServerList 	= File with the list of servernames for which to provide drive statistics; one per line.
	$ReportFileName = The outputted HTML filename and location
	$EmailTo 	= Who should receive the report via email
	$EmailFrom 	= Sender email address
	$EmailSubject 	= Subject for the email
	$SMTPServer 	= SMTP server name
	$DateStamp 	= the format of dates shown in the report.
	$Warning 	= % threshold to indicate Warning color (Yellow) in report.
	$Critical 	= % threshold to indicate Critical color (RED) in report.
================================================================================================#>
$ServerList = "C:\Users\$env:USERNAME\Desktop\AllSatelliteServers.txt"
$ReportFileName = "C:\Users\$env:USERNAME\Desktop\Radia_Servers_Disk_Space_Reports.html"
$DateStamp = (Get-Date -Format D)
$EmailSubject = "Server Disk Space Report for $DateStamp"
$SMTPServer = "smtp.example.com"


# Thresholds: % of available disk space to trigger colors in report. Warning is yellow, Critical is red
$warning = 25
$critical = 5

# Clear the display, show information if running locally.
Clear
Write-Host "*******************************************************************************" -foregroundcolor "Green"
Write-Host "File Name	 	: Disk_Space_Reports.ps1"              		     -foregroundcolor "Green"                                                                                         
Write-Host "Purpose 	 	: Disk_Space_Reports will send an email" 		     -foregroundcolor "Green"                        
Write-Host "Version		 	: 12.21.17"           								             -foregroundcolor "Green"
Write-Host "Date		 	: 2/21/2018"           							             -foregroundcolor "Green"
Write-Host "Author	 	    : Brandon Stevens"    					                         -foregroundcolor "Green" 
Write-Host "Editor Author	: Brandon Stevens"    					      	                 -foregroundcolor "Green" 
Write-Host "Purpose		 	: Servers_Disk_Space_Reports"			    	             -foregroundcolor "Green"  
Write-Host "Requires	 	: PowerShell V4 or Higher"           				             -foregroundcolor "Green"          
Write-Host "*******************************************************************************" -foregroundcolor "Green"
Write-Host


# Create output file and nullify display output
New-Item -ItemType file $ReportFileName -Force > $null


# Write the HTML Header to the file
Add-Content $ReportFileName "<html>"
Add-Content $ReportFileName "<head>"
Add-Content $ReportFileName "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"
Add-Content $ReportFileName '<title>Server Drive Space Report</title>'
Add-Content $ReportFileName '<STYLE TYPE="text/css">'
Add-Content $ReportFileName "td {"
Add-Content $ReportFileName "font-family: Cambria;"
Add-Content $ReportFileName "font-size: 11px;"
Add-Content $ReportFileName "border-top: 1px solid #999999;"
Add-Content $ReportFileName "border-right: 1px solid #999999;"
Add-Content $ReportFileName "border-bottom: 1px solid #999999;"
Add-Content $ReportFileName "border-left: 1px solid #999999;"
Add-Content $ReportFileName "padding-top: 0px;"
Add-Content $ReportFileName "padding-right: 0px;"
Add-Content $ReportFileName "padding-bottom: 0px;"
Add-Content $ReportFileName "padding-left: 0px;"
Add-Content $ReportFileName "}"
Add-Content $ReportFileName "body {"
Add-Content $ReportFileName "margin-left: 5px;"
Add-Content $ReportFileName "margin-top: 5px;"
Add-Content $ReportFileName "margin-right: 0px;"
Add-Content $ReportFileName "margin-bottom: 10px;"
Add-Content $ReportFileName "table {"
Add-Content $ReportFileName "border: thin solid #000000;"
Add-Content $ReportFileName "}"
Add-Content $ReportFileName "</style>"
Add-Content $ReportFileName "</head>"
Add-Content $ReportFileName "<body>"
Add-Content $ReportFileName "<table width='75%' align=`"center`">"
Add-Content $ReportFileName "<tr bgcolor='#CCCCCC'>"
Add-Content $ReportFileName "<td colspan='7' height='25' align='center'>"
Add-Content $ReportFileName "<font face='Cambria' color='#003399' size='4'><strong>Server Disk Space Report<br/></strong></font>"
Add-Content $ReportFileName "<font face='Cambria' color='#003399' size='2'>$DateStamp</font>"  
Add-Content $ReportFileName "</td>"
Add-Content $ReportFileName "</tr>"
Add-Content $ReportFileName "</table>"


# Add color descriptions here
Add-content $ReportFileName "<table width='50%' align=`"center`">"  
Add-Content $ReportFileName "<tr>"  
Add-Content $ReportFileName "<td width='10%' bgcolor='#4CBB17' align='center'><B>Good > $Warning% Free</B></td>"  
Add-Content $ReportFileName "<td width='10%' bgcolor='#FFFC33' align='center'><B>Warning $Critical-$Warning% Free</B></td>"  
Add-Content $ReportFileName "<td width='10%' bgcolor='#155.49.20.214' align='center'><B>Critical < $Critical% Free</B></td>"  
Add-Content $ReportFileName "</tr>"  
Add-Content $ReportFileName "</table>"


# Function to write the Table Header to the file
Function writeTableHeader
{
	param($fileName)
	Add-Content $fileName "<tr bgcolor=#CCCCCC>"
	Add-Content $fileName "<td width='10%' align='center'>Drive</td>"
	Add-Content $fileName "<td width='10%' align='center'>Drive Label</td>"
	Add-Content $fileName "<td width='15%' align='center'>Total Capacity (GB)</td>"
	Add-Content $fileName "<td width='15%' align='center'>Used Capacity (GB)</td>"
	Add-Content $fileName "<td width='15%' align='center'>Free Space (GB)</td>"
	Add-Content $fileName "<td width='10%' align='center'>Free Space %</td>"
	Add-Content $fileName "</tr>"
}


# Function to write the HTML Footer to the file
Function writeHtmlFooter
{
	param($fileName)
	Add-Content $fileName "</body>"
	Add-Content $fileName "</html>"
}


# Function to write Disk info to the file
Function writeDiskInfo
{
	param(
			$fileName
			,$devId
			,$volName
			,$frSpace
			,$totSpace
		)
	$totSpace 	= [math]::Round(($totSpace/1073741824),2)
	$frSpace 	= [Math]::Round(($frSpace/1073741824),2)
	$usedSpace 	= $totSpace - $frspace
	$usedSpace 	= [Math]::Round($usedSpace,2)
	$freePercent 	= ($frspace/$totSpace)*100
	$freePercent 	= [Math]::Round($freePercent,0)
	Add-Content $fileName "<tr>"
	Add-Content $fileName "<td align='center'>$devid</td>"
	Add-Content $fileName "<td align='center'>$volName</td>"
	Add-Content $fileName "<td align='right'>$totSpace</td>"
	Add-Content $fileName "<td align='right'>$usedSpace</td>"
	Add-Content $fileName "<td align='right'>$frSpace</td>"

	if ($freePercent -gt $Warning)
	{
	# bgcolor='#4CBB17' = Green for Good
		Add-Content $fileName "<td bgcolor='#4CBB17' align='center'>$freePercent</td>"
		Add-Content $fileName "</tr>"
	}
	elseif ($freePercent -le $Critical)
	{
	# bgcolor='#155.49.20.214' = Red for Critical
		Add-Content $fileName "<td bgcolor='#155.49.20.214' align=center>$freePercent</td>"
		Add-Content $fileName "</tr>"
	}
	else
	{
	# bgcolor='#FFFC33' = Yellow for Warning
		Add-Content $fileName "<td bgcolor='#FFFC33' align=center>$freePercent</td>"
		Add-Content $fileName "</tr>"
	}
}


foreach ($server in Get-Content $serverlist)
{
	try {
		$ServerName = [System.Net.Dns]::gethostentry($server).hostname
		}
	catch [System.DivideByZeroException] {
		Write-Host "DivideByZeroException: "
		$_.Exception
		Write-Host
		if ($_.Exception.InnerException) {
			Write-Host "Inner Exception: "
			$_.Exception.InnerException.Message # display the exception's InnerException if it has one
			}
		"Continuing..."
		continue
		}
	catch [System.UnauthorizedAccessException] {
		Write-Host "System.UnauthorizedAccessException"
		$_.Exception
		Write-Host
		if ($_.Exception.InnerException) {
			Write-Host "Inner Exception: "
			$_.Exception.InnerException.Message # display the exception's InnerException if it has one
			}
		"Continuing..."
		continue
		}
	catch [System.Management.Automation.RuntimeException] {
		Write-Host "RuntimeException"
		$_.Exception
		Write-Host
		if ($_.Exception.InnerException) {
			Write-Host "Inner Exception: "
			$_.Exception.InnerException.Message # display the exception's InnerException if it has one
			}
		"Continuing..."
		continue
		}	
	catch [System.Exception] {
		Write-Host "Exception connecting to $Server" 
		$_.Exception
		Write-Host
		if ($_.Exception.InnerException) {
			Write-Host "Inner Exception: "
			$_.Exception.InnerException.Message # display the exception's InnerException if it has one
			}
		"Continuing..."
		continue
		}	

	if ($ServerName -eq $null) {
			$ServerName = $Server
			}

# Begin Server Disk tables
	Add-Content $ReportFileName "</table>"
	Add-Content $ReportFileName "<br>"
	Add-Content $ReportFileName "<table width='75%' align=`"Center`">"
	Add-Content $ReportFileName "<tr bgcolor='#CCCCCC'>"
	Add-Content $ReportFileName "<td width='75%' align='center' colSpan=6><font face='Cambria' color='#003399' size='2'><strong> $Server </strong></font></td>"
	Add-Content $ReportFileName "</tr>"

	writeTableHeader $ReportFileName

	$dp = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3" -Computer $server

	foreach ($item in $dp)
	{
		Write-Host  $ServerName $item.DeviceID  $item.VolumeName $item.FreeSpace $item.Size
		writeDiskInfo $ReportFileName $item.DeviceID $item.VolumeName $item.FreeSpace $item.Size
	}
	$ServerName = $NULL
#	Add-Content $ReportFileName "<br>"
}

writeHtmlFooter $ReportFileName

# Send Email 
$BodyReport = Get-Content "$ReportFileName" -Raw
Send-MailMessage	-To		$EmailTo `
		 	-Subject 	$EmailSubject `
			-From 		$EmailFrom `
			-SmtpServer 	$SMTPServer `
			-BodyAsHtml	-Body $BodyReport

}