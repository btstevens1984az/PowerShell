'Maintenance Mode Tool for SCOM 2007 R2
'Written by Cory Anderson 01/12/2012
'
'This script writes data to a text file on the SCOM RMS server
'The text file is monitored for incoming data
'If data is found, an event will be written to the
'Application log on the SCOM RMS server (EventID 4, Source WSH)
'SCOM is monitoring for this event and will process the Description
'through a Powershell script to put the requested server(s) into
'Maintenance Mode in SCOM.
'
'This script accepts command line arguments, but will prompt for
'the necessary information if it is not provided
'
'Command line usage:
'cscript MMTool_v1.vbs /Target:<computername> /DateTime:<mm/dd/yyyy hh:mm am/pm> /Duration:<minutes>
'
'/Target (required) - NetBIOS computer name.  Script will truncate
'the computer name if the FQDN is provided.
'
'/DateTime (optional) - If the DateTime argument is not provided,
'it will default to now.
'
'/Duration (optional) - If the Duration argument is not provided,
'it will default to 60 minutes.


Set ofs = CreateObject("Scripting.FileSystemObject")

sComputer = ""
sStartDT = ""
sDuration = ""
sUserID = ""
sUserPC = ""
sOutFile = "\\186.189.182.154\MaintModeTool\Inbox.txt"


'***** Check Arguments *****
If NOT wscript.Arguments.Count = 0 Then
	ArgCount = 0
	Set NamedArgs = wscript.Arguments.Named

	If NamedArgs.Exists("Target") Then
		sComputer = NamedArgs.Item("Target")
		ArgCount = ArgCount + 1
	Else
		msgbox "/Target:<computername> is a required argument"
		wscript.quit
	End If

	If NamedArgs.Exists("DateTime") Then
		sStartDT = NamedArgs.Item("DateTime")
		ArgCount = ArgCount + 1
	Else
		sStartDT = NOW
	End If

	If NamedArgs.Exists("Duration") Then
		sDuration = NamedArgs.Item("Duration")
		ArgCount = ArgCount + 1
	Else
		sDuration = 60
	End If

	If ArgCount < wscript.Arguments.Count Then 
		msgbox "Unknown arguments received"
		wscript.quit
	End If
End If



'***** Assign Variables if required Arguments are not found *****
If sComputer = "" Then
	sComputer = inputbox("Enter computer name to put into maintenance mode", "Target", "172.153.153.220")
	If sComputer = "" Then
		wscript.quit
	End If
End If

CheckFQDN = InStr(sComputer,".")

If CheckFQDN > 0 Then
	ParseComputer = Split(sComputer, ".")
	sComputer = ParseComputer(0)
End If

If sStartDT = "" Then
	sStartDT = inputbox("Enter date and time to start maintenance mode:", "DateTime", NOW)
	If sStartDT = "" Then
		wscript.quit
	End If
End If

If sDuration = "" Then
	sDuration = inputbox("Enter the maintenance mode duration in minutes:", "Duration", 60)
	If sDuration = "" Then
		wscript.quit
	End If
End If


'***** Get logged on UserID *****
Set objWMI = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")

Set colItems = objWMI.ExecQuery("Select * From Win32_ComputerSystem")
sUserID = ""
sUserPC = ""

For Each objItem in colItems
	sUserID = sUserID & objItem.UserName
	sUserPC = sUserPC & objItem.Name
Next

'RequestTime, ComputerName, StartDateTime, Duration, RequestingUser, RequestingComputer
LogIt NOW & "," & sComputer & "," & sStartDT & "," & sDuration & "," & sUserID & "," & sUserPC
'msgbox NOW & "," & sComputer & "," & sStartDT & "," & sDuration & "," & sUserID & "," & sUserPC

'msgbox "Finished"
wscript.quit


'***** LogIt Subroutine *****	
Sub LogIt(text)
	Set Output = ofs.OpenTextFile(sOutFile, 8, true, -2)
	Output.WriteLine text
	Output.Close
End Sub

