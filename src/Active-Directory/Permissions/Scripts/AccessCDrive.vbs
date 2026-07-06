'*******************************************************************
'Script to Access the Local C Drive on a Remote Workstation
'Brandon Stevens
'Created 01/21/2017
'*******************************************************************

Option Explicit

Dim colComputers, colComputer
Dim objNetwork, objComputer, objPing, objStatus, objWMIService, objShell
Dim strComputer, strTitle, strPing

Set objNetwork = CreateObject("WScript.Network") 
strTitle = "List Currently Logged-on User Utility"

'**** Prompt for IP Address or Computer Name ****
Do Until strPing = True
strComputer = InputBox("Enter IP Address or Computer Name (leave blank for local computer)." & vbcrlf & vbcrlf & vbcrlf & vbcrlf & "(i.e. Hostname or 231.249.251.31)", strTitle)
If IsEmpty(strComputer) Then WScript.Quit
strComputer = Trim(strComputer)
If strComputer = "" Then strComputer = objNetwork.ComputerName

colComputers = split(strComputer, ";")
For Each objComputer In colComputers
	Set objPing = GetObject("winmgmts:").ExecQuery("select * from Win32_PingStatus where address = '" & objComputer & "'")
	For Each objStatus In objPing
		If IsNull(objStatus.StatusCode) Or objStatus.StatusCode<>0 Then
			MsgBox strComputer & " is not online or you have entered an invalid IP Address or Computer Name." & vbcrlf & "Please re-enter the IP Address or Computer Name" & vbcrlf & vbcrlf & "Click 'OK' to continue.", vbOKOnly, strTitle
		Else
			strPing = True
		End If
	Next
Next
Loop

'**** Access C Drive ****
Set objShell = CreateObject("WScript.Shell")
objShell.Run("\\" & strComputer & "\c$")
WScript.Quit
