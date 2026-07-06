# Purpose: Get-RadiaServerHealthReport — HP Radia client automation and satellite servers.
function Get-RadiaServerHealthReport{
<#===================================================================================================================
Script Name:  Get-RadiaServerHealthReport
Purpose:  Produces a Health Report for servers. List of servers is fed from a text file.
Notes:  Originally this was just a drive space report but I edited to include RAM, CPU, and UPTIME info.
Last Revised:  1:55 PM 01/17/2018
Revised By:  Brandon Stevens
Revision Notes:  Added Font colors for RAM and UPTIME to indicate health stats.
		
=====================================================================================================================
Edit these with your preferences in the section following this one:
	$DateStamp 	= the format of dates shown in the report.
	$ServerList 	= File with the list of servernames for which to provide drive statistics; one per line.
	$ReportFileName = The outputted HTML filename and location
	$ReportTitle 	= Name of the report that is shown in the generated HTML file and in email subject.
	$EmailTo 	= Who should receive the report via email
	$EmailFrom 	= Sender email address
	$EmailSubject 	= Subject for the email
	$SMTPServer 	= SMTP server name
	$Warning 	= Free drive space % to indicate Warning (Yellow) in report. Must be more than $Critical amount.
	$Critical 	= Free drive space % to indicate Critical (RED) in report. Must be less than $Warning amount.
	$BGColorTbl	= Background color for tables.
	$BGColorGood 	= Background color for "Good" results. #4CBB17 is green.
	$BGColorWarn 	= Background color for "Warning" results. #FFFC33 is yellow.
	$BGColorCrit 	= Background color for "Critical" results. #155.49.20.214 is red.
	$UptimeDayMax	= Number of days of uptime to be alerted to if exceeded
	$RAMFree	= Percentage of free RAM to be alerted to if less than
======================================================================================================================#>
$DateStamp = (Get-Date -Format D)
$ServerList = "\\186.189.182.154\share"
$ReportFileName = "\\186.189.182.154\share"
$ReportTitle = "Server Health Report"
$EmailSubject = "Radia Server Health Report for $DateStamp"
$SMTPServer = "smtp.example.com"
$BGColorTbl = "#EAECEE"
$BGColorGood = "#4CBB17"
$BGColorWarn = "#FFFC33"
$BGColorCrit = "#155.49.20.214"
$UptimeDayMax = 180
$RAMFree = 15

# Thresholds: % of available disk space to trigger colors in report. Warning is yellow, Critical is red
$Warning = 15
$Critical = 5

<#=============================
Do not edit below this section
=============================#>
# Clear screen then show progress
Clear
Write-Host "Creating report..." -foreground "Yellow"

# Create output file and nullify display output
New-Item -ItemType file $ReportFileName -Force > $null

# Write the HTML Header to the file
Add-Content $ReportFileName "<html>"
Add-Content $ReportFileName "<head>"
Add-Content $ReportFileName "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"
Add-Content $ReportFileName '<title>Server Health Report</title>'
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
Add-Content $ReportFileName "<tr bgcolor=$BGColorTbl>"
Add-Content $ReportFileName "<td colspan='7' height='25' align='center'>"
Add-Content $ReportFileName "<font face='Cambria' color='#003399' size='4'><strong>$ReportTitle<br/></strong></font>"
Add-Content $ReportFileName "<font face='Cambria' color='#003399' size='2'>$DateStamp</font><br><br>"  
Add-Content $ReportFileName "<b>Thresholds: </b>RAM will be in <FONT color=$BGColorCrit>RED</FONT> if free % is less than $RAMFree. UPTIME will be in <FONT color=$BGColorCrit>RED</FONT> if greater than $UptimeDayMax days.</FONT>"
Add-Content $ReportFileName "</td>"
Add-Content $ReportFileName "</tr>"
Add-Content $ReportFileName "</table>"

# Add color descriptions here
Add-content $ReportFileName "<table width='60%' align=`"center`">"  
Add-Content $ReportFileName "<tr>"  
Add-Content $ReportFileName "<td width='20%' bgcolor=$BGColorGood align='center'><B>Disk Space > $Warning% Free</B></td>"  
Add-Content $ReportFileName "<td width='20%' bgcolor=$BGColorWarn align='center'><B>Disk Space $Critical-$Warning% Free</B></td>"  
Add-Content $ReportFileName "<td width='20%' bgcolor=$BGColorCrit align='center'><B>Disk Space < $Critical% Free</B></td>"
Add-Content $ReportFileName "</tr>"
Add-Content $ReportFileName "</table>"

# Function to write the Table Header to the file
Function writeTableHeader
{
	param($fileName)
	Add-Content $fileName "<tr bgcolor=$BGColorTbl>"
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
		Add-Content $fileName "<td bgcolor=$BGColorGood align='center'>$freePercent</td>"
		Add-Content $fileName "</tr>"
	}
	elseif ($freePercent -le $Critical)
	{
	# bgcolor='#155.49.20.214' = Red for Critical
		Add-Content $fileName "<td bgcolor=$BGColorCrit align=center>$freePercent</td>"
		Add-Content $fileName "</tr>"
	}
	else
	{
	# bgcolor='#FFFC33' = Yellow for Warning
		Add-Content $fileName "<td bgcolor=$BGColorWarn align=center>$freePercent</td>"
		Add-Content $fileName "</tr>"
	}
}

Write-Host "Collecting data for servers in list..." -foreground "Yellow"
Write-Host
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

	Add-Content $ReportFileName "</table>"
	Add-Content $ReportFileName "<br>"

# CPU Info
$CPUs = (Get-WMIObject Win32_ComputerSystem -Computername $ServerName).numberofprocessors
$TotalCores = 0 
Get-WMIObject -computername $ServerName -class win32_processor | ForEach {$TotalCores = $TotalCores + $_.numberofcores}

# RAM Info
$ComputerSystem = Get-WmiObject -ComputerName $Servername -Class Win32_operatingsystem -Property CSName, TotalVisibleMemorySize, FreePhysicalMemory
$MachineName = $ComputerSystem.CSName
$FreePhysicalMemory = ($ComputerSystem.FreePhysicalMemory) / (1mb)
$TotalVisibleMemorySize = ($ComputerSystem.TotalVisibleMemorySize) / (1mb)
$TotalVisibleMemorySizeR = "{0:N2}" -f $TotalVisibleMemorySize
$TotalFreeMemPerc = ($FreePhysicalMemory/$TotalVisibleMemorySize)*100
$TotalFreeMemPercR = "{0:N2}" -f $TotalFreeMemPerc
If ($TotalCores -eq 1)
	{$CPUSpecs = "CPU: $CPUs with 1 core"}
else
	{$CPUSpecs = "CPU: $CPUs with $TotalCores cores"}
$RAMSpecs = "RAM: $TotalVisibleMemorySizeR GB with $TotalFreeMemPercR% free"

# Uptime
$BootTime = (Get-WmiObject win32_operatingSystem -computer $ServerName -ErrorAction stop).lastbootuptime
$BootTime = [System.Management.ManagementDateTimeconverter]::ToDateTime($BootTime)
$Now = Get-Date
$span = New-TimeSpan $BootTime $Now 
	$Days	 = $span.days
	$Hours   = $span.hours
	$Minutes = $span.minutes 
	$Seconds = $span.seconds

# Remove plurals if the value = 1
	If ($Days -eq 1)
		{$Day = "1 day "}
	else
		{$Day = "$Days days "}

	If ($Hours -eq 1)
		{$Hr = "1 hr "}
	else
		{$Hr = "$Hours hrs "}

	If ($Minutes -eq 1)
		{$Min = "1 min "}
	else
		{$Min = "$Minutes mins "}

	If ($Seconds -eq 1)
		{$Sec = "1 sec"}
	else
		{$Sec = "$Seconds secs"}

$Uptime = $Day + $Hr + $Min + $Sec
$ServerUptime = "UPTIME: " + $Uptime

#Set FONT color for health stats visual alerts
#% of free RAM
IF ($TotalFreeMemPerc -le $RAMFree)
	{
		$FontColorRAM=$BGColorCrit
	}
	Else
	{
		$FontColorRAM=$BGColorGood
	}

#UPTime days
IF ($Days -gt $UptimeDayMax)
	{
		$FontColorUp=$BGColorCrit
	}
	Else
	{
		$FontColorUp=$BGColorGood
	}

Add-Content $ReportFileName "<table width='75%' align=`"Center`">"
Add-Content $ReportFileName "<tr bgcolor=$BGColorTbl>"
Add-Content $ReportFileName "<td width='75%' align='center' colSpan=6><font face='Cambria' color='#003399' size='2'><strong> $Server </strong></font><br>"
Add-Content $ReportFileName "$CPUSpecs<br>"
Add-Content $ReportFileName "<FONT face='Cambria' color=$FontColorRAM>$RAMSpecs<br>"
Add-Content $ReportFileName "<FONT face='Cambria' color=$FontColorUp>$ServerUptime</td>"
Add-Content $ReportFileName "</tr>"
writeTableHeader $ReportFileName

# Begin Server Disk tables
	$dp = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3" -Computer $server
	foreach ($item in $dp)
	{
		Write-Host  $ServerName $item.DeviceID  $item.VolumeName $item.FreeSpace $item.Size
		writeDiskInfo $ReportFileName $item.DeviceID $item.VolumeName $item.FreeSpace $item.Size
	}
	$ServerName = $NULL
#	Add-Content $ReportFileName "<br>"
}

Write-Host "Finishing report..." -foreground "Yellow"
writeHtmlFooter $ReportFileName
Write-Host

# Send Email
$BodyReport = Get-Content "$ReportFileName" -Raw
$StopEmailLoop=$false
[int]$RetryCount=0

Do {
	Try {
			Send-MailMessage -To $EmailTo `
			-Subject 	$EmailSubject `
			-From 		$EmailFrom `
			-SmtpServer 	$SMTPServer `
			-BodyAsHtml	-Body $BodyReport `
			-ErrorAction Stop;
			Write-Host "Sending email..."
			$StopEmailLoop = $true
		}
		Catch {
				If ($RetryCount -gt 5){
					Write-Host "Cannot send email. The script will exit."
					$StopEmailLoop = $true
					}
				Else {
					Write-Host "Cannot send email. Trying again in 15 seconds..."
					Start-Sleep -Seconds 15
					$RetryCount = $RetryCount+1
					}
		}
	}
While ($StopEmailLoop -eq $false)
}