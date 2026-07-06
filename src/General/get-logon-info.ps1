# Purpose: get-logon info — General-purpose PowerShell utilities.
# Connects to the security eventlog of a remote computer and retrieves successful login events ( event ID 528 ) and what type of login took place

# Information about login types found at http://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventid=528

#





$events =  Get-EventLog -ComputerName 22.214.190.62 -LogName "Security" -newest 10000 | Where {$_.eventid -eq 528 -AND $_.Source -eq "Security" } 



foreach ( $event in $events	 ) {

	if (($event.message | Select-String "Logon Type:	2")){

		"LogonType 2 (Interactive Login );"+ $event.TimeGenerated.DateTime + ";" +$event.UserName		

	}

	if (($event.message | Select-String "Logon Type:	3")){

		"LogonType 3 (Network Login )    ;"+ $event.TimeGenerated.DateTime + ";" +$event.UserName		

	}

	if (($event.message | Select-String "Logon Type:	4")){

		"LogonType 4 (Batch Login )      ;"+ $event.TimeGenerated.DateTime + ";" +$event.UserName		

	}

	if (($event.message | Select-String "Logon Type:	5")){

		"LogonType 5 (Service Login )    ;"+ $event.TimeGenerated.DateTime + ";" +$event.UserName		

	}

	if (($event.message | Select-String "Logon Type:	7")){

		"LogonType 7 (Computer Unlocked );"+ $event.TimeGenerated.DateTime + ";" +$event.UserName		

	}

	if (($event.message | Select-String "Logon Type:	8")){

		"LogonType 8 (Network Cleartext Login );"+ $event.TimeGenerated.DateTime + ";" +$event.UserName		

	}

	if (($event.message | Select-String "Logon Type:	9")){

		"LogonType 9 (NewCredentials )   ;"+ $event.TimeGenerated.DateTime + ";" +$event.UserName		

	}

	if (($event.message | Select-String "Logon Type:	10")){

		"LogonType 10 (RDP Login )       ;"+ $event.TimeGenerated.DateTime + ";" +$event.UserName

	}

	if (($event.message | Select-String "Logon Type:	11")){

		"LogonType 11 (Cached Credentials Login );"+ $event.TimeGenerated.DateTime + ";" +$event.UserName		

	}

}