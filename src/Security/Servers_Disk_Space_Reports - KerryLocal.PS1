# Purpose: Servers_Disk_Space_Reports - KerryLocal — Security auditing and compliance checks.
#************************************************************************************************************************
$ErrorActionPreference = "SilentlyContinue"
Set-ExecutionPolicy remotesigned -Force $ErrorActionPreference
Clear-Host
Write-Host "*******************************************************************************" -foregroundcolor "Green"
Write-Host "File Name	 	: Servers_Disk_Space_Reports.ps1"              		-foregroundcolor "Green"                                                                                         
Write-Host "Purpose 	 	: Servers_Disk_Space_Reports to sent an email" 		-foregroundcolor "Green"                        
Write-Host "Version		 	: 01.08.17"           								-foregroundcolor "Green"
# Write-Host "Date		 	: 12/28/2016"           							-foregroundcolor "Green"
Write-Host "Date		 	: 08/16/2017"           							-foregroundcolor "Green"
# Write-Host "Author	 	:	 Karthikeyan Anbarasu"    					    -foregroundcolor "Green" 
Write-Host "Editor Author		: Kerry Kreitinger"    					      		-foregroundcolor "Green" 
Write-Host "Purpose		 	: Servers_Disk_Space_Reports"			    		-foregroundcolor "Green"  
Write-Host "Requires	 	: PowerShell V4 or Higher"           				-foregroundcolor "Green"          
Write-Host "*******************************************************************************" -foregroundcolor "Green"
#****************************** script Path *****************************************************************************
$OutputPath = split-path -parent $MyInvocation.MyCommand.Definition
#$OutputPath = "C:\PSReports\"
#****************************** Info *****************************************************************
$Title = "Servers Disk Space Reports"                               	#DailyCheck Report Title
#***************************** SMTP  change the Value to Yes and add SMTP Server to send email report *******************
$TriggerMail = "Yes"
write-host "Email is set to  " $TriggerMail 				            #If Yes then enabled else disabled
$smtpserver = "smtp.example.com"                    				#SMTP Server Name
$ccaddress = ""       			        								#Cc Address
$bccaddress = ""       			                    					#Bcc Address
#***************************** Developer Information ********************************************************************
$DeveloperName = "Kerry Kreitinger"										#Developer Name
#***************************** Warning Parameters - CSV desired  ********************************************************
$CheckDiskSpaceRpt = "Yes"                                    			#If Yes then Check Servers availablity

$GenerateCSVRpt = "No"
write-host "Create CSV report is set to  " $generateCSVRpt           #If Yes then Generate CSV Rpt
$PercentageWarning = "15"                                               #Percentage Warning
$PercentageCritical = "10"                                              #Percentage Critical
#************************************************************************************************************************

#************************************************************************************************************************
# Delete previous files prior to writing new 
Remove-Item -path "C:\inetpub\wwwroot\Servers_Disk_Space_log.html" -Force
Remove-Item -path "C:\inetpub\wwwroot\Servers_Disk_Space_Reports.html" -Force
$Report = "C:\inetpub\wwwroot\Servers_Disk_Space_Reports.html"
# $CSVReport = "$OutputPath\Servers_Disk_Space_Reports.CSV" 
$Logfile = "C:\inetpub\wwwroot\Servers_Disk_Space_Log.html"
#***************************************** Input list os systems and path ***********************************************
$strServers = "$OutputPath\ServersList.txt"
If(Test-Path -path "$strServers")
{
    $strServers = Get-Content $strServers
}
Else
{
	Add-Content $logfile -Value "****************** Start Time: $(Get-Date) ******************* <br> "
    Write-Host "****************** Start Time: $(Get-Date) ******************* "
 	Write-Host "Error: No Input File exists on Input folder Path: $strServers  "
    Add-Content $logfile -Value "Error: No Input File exists on Input folder Path: $strServers <br> "
    Add-Content $logfile -Value "****************** End Time: $(Get-Date) ******************* <br> "
    Write-Host "****************** End Time: $(Get-Date) ******************* <br> "
	Exit 1
}
#**************************** Report Name and Date Time executed **************************************
$ReportTitle = "$ProjectName - Servers Disk Space Reports - $(get-date -Format F)"
$TextColor = "white"
#************************************************************************************************************************
##while ($true) { write-progress  -Activity 'Checking on Valid Parameters'; sleep 1 }
#
#

Function Get-DailyHTMLReport
{
	Add-Content $logfile -Value "****************** Start Time: $(Get-Date) ******************* <br> "
    Write-Host "****************** Start Time: $(Get-Date) *******************"
	#Create a new report file to be emailed out
	New-Item -ItemType File -Name $Report -Force | Out-Null
	New-Item -ItemType File -Name $CSVReport -Force | Out-Null
	#Write the HTML header information to file
	writeHtmlHeader "$Path\$Report"
    #Checking Servers Details Status Report
    If ($CheckDiskSpaceRpt -eq "Yes")
    {
        Add-Content $logfile -Value "$(Get-Date) : Checking Servers Disk Space Reports Details <br> "
        Write-Host "$(Get-Date) : Checking Servers Disk Space Reports Details"
        $rptheader=@"
        <table width='100%'><tbody>
   	    <tr bgcolor=#01A982> <td> <b> <Font color = 'white'> Servers Disk Space Details Report </Font> </b> </td> </tr>
        </table>
        <table width='100%' border = 0 > <tbody>
	    <tr bgcolor=#CCCCCC>
		<td width='5%'>S.No</td>
		<td width='20%'>ServerName</td>
		<td width='10%'>Drive</td>
		<td width='10%'>Total Capacity(GB)</td>
		<td width='10%'>Used Capacity(GB)</td>
		<td width='10%'>Free Space(GB)</td>
		<td width='10%'>Free Space%</td>
		<td width='5%'>Status</td>
	    </tr>
        </table>
"@
		If ($GenerateCSVRpt -eq "Yes")
		{
			Add-Content $CSVReport -Value "SNo,ServerName,DeviceID,SizeGB,UsedSpaceGB,FreeSpaceGB,PercentFree,Status" 
		}
        $i = 1
        foreach ($Server in $strServers)
		{
			$Server = $Server.toupper()
			$Ping = Get-WmiObject -Query "Select * from win32_PingStatus where Address='$Server'"
			If($Ping.StatusCode -eq 0)
			{
				$IPAddress = $Ping.IPV4Address
				If(Test-Path \\$Server\C$)
				{
					$Wmi = Get-WmiObject -ComputerName $Server -Namespace root\cimv2 -class Win32_OperatingSystem
					If ($Wmi)
					{
						$disks = Get-WmiObject -ComputerName $Server -Class Win32_LogicalDisk -Filter "DriveType = 3"
						foreach($disk in $disks)
						{
							 $deviceID = $disk.DeviceID;
							 If ($deviceID -ne $ExcludeDriveLetter)
							 {
								$volName = $disk.VolumeName
								[float]$size = $disk.Size
								[float]$freespace = $disk.FreeSpace
								$percentFree = [Math]::Round(($freespace / $size) * 100, 2)
								$sizeGB = [Math]::Round($size / 1073741824, 2)
								$freeSpaceGB = [Math]::Round($freespace / 1073741824, 2)
								#$usedSpaceGB = $sizeGB - $freeSpaceGB
								$usedSpaceGB = [Math]::Round($sizeGB - $freeSpaceGB ,2)
								# Set background color to Yellow If just a Warning
								If($percentFree -lt $PercentageWarning)      
								{
									$Status = "Warning"
									$color = "Orange"
									$temp = "Yes"
									# Set background color to Yellow If space is Critical                                
									If($percentFree -lt $PercentageCritical)
									{
										$Status = "Critical"
										$color = "Red"
										$temp = "Yes"
										Add-Content $CSVReport -value "$i,$Server,$deviceID,$sizeGB,$usedSpaceGB,$freeSpaceGB,$percentFree,$Status"
									}
									Add-Content $CSVReport -value "$i,$Server,$deviceID,$sizeGB,$usedSpaceGB,$freeSpaceGB,$percentFree,$Status"  
								}  
								else
								{
									$Status = "Ok"
									$color = 'Green'
									$temp = "Yes"
									Add-Content $CSVReport -value "$i,$Server,$deviceID,$sizeGB,$usedSpaceGB,$freeSpaceGB,$percentFree,$Status"
								}
								If ($temp -eq "Yes")
								{
									$z++
									If ($z -eq 1)
									{
										Add-Content "$Report" $rptheader                                    
									}
									$Rpt=@"
									<table width='100%' border = 0 > <tbody>
									<tr align='center'>
									<td width='5%' align='center' >$i</td>
									<td width='20%'>$Server</td> 
									<td width='10%'>$deviceID</td>    
									<td width='10%'>$sizeGB</td>
									<td width='10%'>$usedSpaceGB</td>
									<td width='10%'>$freeSpaceGB</td>
									<td width='10%'>$percentFree</td>
									<td width='5%' align='center' bgcolor='$color'> <Font color ='$TextColor'> $Status </Font> </td>
									</tr>
									</table>
"@
									Add-Content "$Report" $Rpt                                
									$temp = "No"
									$i++
								}
							}
						}
					}
					else
					{
						$Status = "Wmi_Issue"
						$Color = "Orange"
						$t = "Yes"
						Add-Content $CSVReport -value "$i,$Server,NA,NA,NA,NA,NA,$Status"
					}
				}
				else
				{
					$Status = "Adm_Issue"
					$Color = "Orange"
					$t = "Yes"
					Add-Content $CSVReport -value "$i,$Server,NA,NA,NA,NA,NA,$Status"
				}           
			}
			else
			{
				$Status = "Offline"
				$Color = "DarkRed"
				$t = "Yes"
				Add-Content $CSVReport -value "$i,$Server,NA,NA,NA,NA,NA,$Status"
			}
			If ($t -eq "Yes")
			{
				$z++
				If ($z -eq 1)
				{
					Add-Content "$Report" $rptheader                
				}
				$Rpt=@"
				<table width='100%' border = 0 > <tbody>
				<tr align= 'center'>
				<td width='5%' align='center' >$i</td>
				<td width='20%'>$Server</td>
				<td width='10%'>NA</td>
				<td width='10%'>NA</td>
				<td width='10%'>NA</td>
				<td width='10%'>NA</td>
				<td width='10%'>NA</td>
				<td width='5%' align='center' bgcolor='$color'> <Font color ='$TextColor'> $Status </Font> </td>
				</tr>
				</table>
"@
				Add-Content "$Report" $Rpt
				$t = "No"
				$i++
			}
		}
    }    
    # Create table at end of report showing legend of colors for the Critical and Warning   ***********************************
	$tableDescription = "
    <table width='30%'>
    <tr bgcolor='White'>
    <td width='10%' align='center' bgcolor='Green'> <Font color = 'white'> <b> Normal >15%</b> </Font> </td>  
	<td width='10%' align='center' bgcolor='Orange'> <Font color = 'white'> <b> Warning <15%</b> </Font> </td>  
	<td width='10%' align='center' bgcolor='Red'> <Font color = 'white'> <b> Critical <10%</b> </Font> </td> 
	<td width='10%' align='center' bgcolor='DarkRed'> <Font color = 'white'> <b> Offline - Ping Failed </b> </Font> </td>
	</tr>
    </table>
    "
    Add-Content $Report $tableDescription	
	$RptFooter1 = @"
    <table width='100%' bgcolor = '#425563'><tbody>
   	<tr> <td align='center'> <b> <Font color = 'white'> Script Configured By : $DeveloperName ( $DeveloperEmailID ) - $(get-date -Format F) </Font> </b> </td> </tr>
	<tr> <td align='center'> <b> <Font color = 'white'> $CompanyName Restricted - Copyright 2017</Font> </b> </td> </tr>
    <tr> <td align='center'> <b> <Font color = 'white'>Click <a href="./Servers_Disk_Space_Log.html" target="_blank"><font color="white">Report Log</font></a> to see Report Log.</Font> </b> </td> </tr>
	</table>
"@
    Add-Content $Report $RptFooter1
	Add-Content "$Report" "</div></div></body></html>"
    # Finish up Report
    #Checking SMPT Mail Sent Details
    If ($TriggerMail -eq "Yes")
    {
        Add-Content $logfile -Value "$(Get-Date) : Sending SMTP Mail Sent Details"
        Write-Host "$(Get-Date) : Sending SMTP Mail Sent Details"
        $Subject = "$ReportTitle"
        $body = get-content "$Report"   
        $message = new-object System.Net.Mail.MailMessage 
        $message.From = $fromaddress 
        $message.To.Add($toaddress)
        $message.Cc.Add($ccaddress)
        $message.Bcc.Add($bccaddress)
        $message.IsBodyHtml = $true
        $message.Subject = $Subject 
        $attach = new-object Net.Mail.Attachment($Report) 
        $message.Attachments.Add($attach) 
		If ($GenerateCSVRpt -eq "Yes")
		{
			$attach = new-object Net.Mail.Attachment($CSVReport) 
			$message.Attachments.Add($attach) 
		}
        $message.body = $body 
        $smtp = new-object Net.Mail.SmtpClient($smtpserver) 
        $smtp.Send($message) 
    }
    Else
    {
        Add-Content $logfile -Value "$(Get-Date) : Skipping SMTP Mail Sent Details <br> "
        Write-Host "$(Get-Date) : Skipping SMTP Mail Sent Details"
    }
    Add-Content $logfile -Value "****************** End Time: $(Get-Date) ******************* <br>"
    Write-Host "****************** End Time: $(Get-Date) *******************"
}
# Write HTML Header information to our Report & Use CSS to make report more readable
Function writeHtmlHeader
{
    $date = (get-date -Format F)
    $header = @"
   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>$Title</title>
    <style type="text/css">
    <!--
    body {
            font: 100%/1.4 Verdana, Arial, Helvetica, sans-serIf;
            background: #FFFFFF;
            margin: 0;
            padding: 0;
            color: #000;
         }
    .container {
            width: 100%;
            margin: 0 auto;
            }
    h1 {
            font-size: 18px;
        }
    h2 {
            color: #FFF;
            padding: 0px;
            margin: 0px;
            font-size: 14px;
            background-color: #006400;
        }
    h3 {
            color: #FFF;
            padding: 0px;
            margin: 0px;
            font-size: 14px;
            background-color: #191970;
        }
    h4 {
            color: #348017;
            padding: 0px;
            margin: 0px;
            font-size: 10px;
            font-style: italic;
        }
    .header {
            text-align: center;
        }
    .container table {
            width: 100%;
            font-family: Verdana, Geneva, sans-serIf;
            font-size: 12px;
            font-style: normal;
            font-weight: bold;
            font-variant: normal;
            text-align: center;
            border: 0px solid black;
            padding: 0px;
            margin: 0px;
        }
    td {
            font-weight: normal;
            border: 1px solid grey;
            width='25%'
        }
    th {
            font-weight: bold;
            border: 1px solid grey;
            text-align: center;
        }
    -->
    </style></head>
    <body>
    <div class="container">
    <div class="content">	
"@
    Add-Content "$Report" $header	
	$RptHeaderSME1 = @"
	<table width='100%'><tbody>
	<tr bgcolor = '#425563'> <td align='center'> <b> 
	<Font color = 'white'> $ReportTitle </Font>

	</b> </td> </tr>
	</table>
"@
    Add-Content $Report $RptHeaderSME1
}

# Run Main Report
Get-DailyHTMLReport $args[0]