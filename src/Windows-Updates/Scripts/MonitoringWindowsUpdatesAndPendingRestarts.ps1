# Purpose: MonitoringWindowsUpdatesAndPendingRestarts — Windows Update and patch management.
﻿#########################################################
#                                                       #
# Monitoring Windows Updates and Pending Restarts       #
#                                                       #
#########################################################

#########################################################
# List of computers to be monitored
#########################################################
$Servers = Get-Content .\Machines.txt

#########################################################
# List of users who will receive the report
#########################################################
$mailto = "mail1@mail.net, mail2@mail.net"

#########################################################
# SMTP properties
#########################################################
$emailFrom = "suport@mail.net"
$smtpServer = "mySMTPServer" #SMTP Server.
$smtpUsername = "myUsername"
$smtpPassword = "myPassword"

$results = foreach ($Computer in $Servers) 
{ 
	try 
  	{ 
	  	$service = Get-WmiObject Win32_Service -Filter 'Name="wuauserv"' -ComputerName $Computer -Ea 0
		$WUStartMode = $service.StartMode
		$WUState = $service.State
		$WUStatus = $service.Status
  	
		try{
			if (Test-Connection -ComputerName $Computer -Count 1 -Quiet)
			{ 
				#check if the server is the same where this script is running
				if($Computer -eq "$env:computername.$env:userdnsdomain")
				{
					$UpdateSession = New-Object -ComObject Microsoft.Update.Session
				}
				else { $UpdateSession = [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session",$Computer)) }
				$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
				$SearchResult = $UpdateSearcher.Search("IsAssigned=1 and IsHidden=0 and IsInstalled=0")
				$Critical = $SearchResult.updates | where { $_.MsrcSeverity -eq "Critical" }
				$important = $SearchResult.updates | where { $_.MsrcSeverity -eq "Important" }
				$other = $SearchResult.updates | where { $_.MsrcSeverity -eq $null }
				# Get windows updates counters
				$totalUpdates = $($SearchResult.updates.count)
				$totalCriticalUp = $($Critical.count)
				$totalImportantUp = $($Important.count)
				
				if($totalUpdates -gt 0)
				{
					$updatesToInstall = $true
				}
				else { $updatesToInstall = $false }
			}
			else
			{
				# if cannot connected to the server the updates are listed as not defined
				$totalUpdates = "nd"
				$totalCriticalUp = "nd"
				$totalImportantUp = "nd"
			}
		}
		catch 
        { 
			# if an error occurs the updates are listed as not defined
        	Write-Warning "$Computer`: $_" 
         	$totalUpdates = "nd"
			$totalCriticalUp = "nd"
			$totalImportantUp = "nd"
			$updatesToInstall = $false
        }
  
        # Querying WMI for build version 
        $WMI_OS = Get-WmiObject -Class Win32_OperatingSystem -Property BuildNumber, CSName -ComputerName $Computer -Authentication PacketPrivacy -Impersonation Impersonate

        # Making registry connection to the local/remote computer 
        $RegCon = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"LocalMachine",$Computer) 
         
        # If Vista/2008 & Above query the CBS Reg Key 
        If ($WMI_OS.BuildNumber -ge 6001) 
        { 
            $RegSubKeysCBS = $RegCon.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\").GetSubKeyNames() 
            $CBSRebootPend = $RegSubKeysCBS -contains "RebootPending" 
        }
		else{
			$CBSRebootPend = $false
		}
           
        # Query WUAU from the registry 
        $RegWUAU = $RegCon.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\") 
        $RegSubKeysWUAU = $RegWUAU.GetSubKeyNames() 
        $WUAURebootReq = $RegSubKeysWUAU -contains "RebootRequired" 
		
		If($CBSRebootPend –OR $WUAURebootReq)
		{
			$machineNeedsRestart = $true
		}
		else
		{
			$machineNeedsRestart = $false
		}
         
        # Closing registry connection 
        $RegCon.Close() 
		
		if($machineNeedsRestart -or $updatesToInstall -or ($WUStartMode -eq "Manual") -or ($totalUpdates -eq "nd"))
		{
			New-Object PSObject -Property @{
	           	Computer = $WMI_OS.CSName 
                WindowsUpdateStatus = $WUStartMode + "/" + $WUState + "/" + $WUStatus 
                UpdatesToInstall = $updatesToInstall 
                TotalOfUpdates = $totalUpdates  
                TotalOfCriticalUpdates = $totalCriticalUp 
				TotalOfImportantUpdates = $totalImportantUp
                RebootPending = $machineNeedsRestart
        	}
		}
  	}
	Catch 
 	{ 
    	Write-Warning "$Computer`: $_" 
  	}
}

#########################################################
# Formating result
#########################################################
$tableFragment = $results | ConvertTo-HTML -fragment

# HTML Format for Output 
$HTMLmessage = @"
<font color=""black"" face=""Arial"" size=""3"">
<h1 style='font-family:arial;'><b>Windows Updates and Pending Restarts Report</b></h1>
<p style='font: .8em ""Lucida Grande"", Tahoma, Arial, Helvetica, sans-serif;'>This report was generated because the server(s) listed below have Windows Updates ready to be installed, Windows Updates configured to be checked manually or servers that required a reboot. Servers that do not fall under these conditions will not be listed.</p>
<br><br>
<style type=""text/css"">body{font: .8em ""Lucida Grande"", Tahoma, Arial, Helvetica, sans-serif;}
ol{margin:0;}
table{width:80%;}
thead{}
thead th{font-size:120%;text-align:left;}
th{border-bottom:2px solid rgb(79,129,189);border-top:2px solid rgb(79,129,189);padding-bottom:10px;padding-top:10px;}
tr{padding:10px 10px 10px 10px;border:none;}
#middle{background-color:#900;}
</style>
<body BGCOLOR=""white"">
$tableFragment
</body>
"@


#########################################################
# Validation and sending email
#########################################################
# Regular expression to get what's inside of <td>'s
$regexsubject = $HTMLmessage
$regex = [regex] '(?im)<td>'

# If you have data between <td>'s then you need to send the email
if ($regex.IsMatch($regexsubject)) {
     $smtp = New-Object Net.Mail.SmtpClient -ArgumentList $smtpServer 
      $smtp.credentials = New-Object System.Net.NetworkCredential($smtpUsername, $smtpPassword); 
      $msg = New-Object Net.Mail.MailMessage
     $msg.From = $emailFrom
     $msg.To.Add($mailto)
     $msg.Subject = "Disk Space Alert for $computer"
     $msg.IsBodyHTML = $true
     $msg.Body = $HTMLmessage    
      $smtp.Send($msg)   
}