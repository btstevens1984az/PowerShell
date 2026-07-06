'*******************************************************************
'Script to Terminate a Process on a Remote or Local Computer
'Brandon Stevens
'Created 01/21/2018
'*******************************************************************

Option Explicit

Dim colProcess
Dim objWMIService, objProcess, objExplorer, objShell, objPing, objStatus, objDocument, objNetwork
Dim strComputer, strProcessKill, strInput, strPSKILL, strList, strProcessList, strVerify, strTitle, strPing

Set objShell = CreateObject("WScript.Shell")
Set objNetwork = CreateObject("WScript.Network")

strPSKILL = "\\29.222.253.230\sysinternals\pskill.exe"
strTitle = "Terminate Process Utility"

'**** Prompt for IP Address or Computer Name and verify the workstation is online ****
Do Until strPing = True
strComputer = InputBox("Enter a Computer Name or IP Address (leave blank for local computer)." & vbcrlf & vbcrlf & vbcrlf & "(i.e. PCHostname or PCIPaddress)", strTitle)
If IsEmpty(strComputer) Then WScript.Quit
strComputer = Trim(strComputer)
If strComputer = "" Then strComputer = objNetwork.ComputerName

Set objPing = GetObject("winmgmts:").ExecQuery("select * from Win32_PingStatus where address = '" & strComputer & "'")
For Each objStatus In objPing
	If IsNull(objStatus.StatusCode) Or objStatus.StatusCode <> 0 Then
		MsgBox strComputer & " is not online or you have entered an invalid Computer Name or IP Address." & vbcrlf & "Please re-enter the Computer Name or IP Address" & vbcrlf & vbcrlf & "Click 'OK' to continue.", vbOKOnly, strTitle
	Else
		strPing = True
	End If
Next
Loop

'**** Display running processes in an IE window ****
Set objExplorer = WScript.CreateObject("InternetExplorer.Application")
objExplorer.Navigate "about:blank"
objExplorer.ToolBar = 0
objExplorer.StatusBar = 0
objExplorer.Width = 250
objExplorer.Height = 500
objExplorer.Left = 0
objExplorer.Top = 0
objExplorer.Visible = 1
objExplorer.Document.Title = strComputer & " processes"

Set objDocument = objExplorer.Document
objDocument.Open
Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set colProcess = objWMIService.ExecQuery ("SELECT * FROM Win32_Process")
For Each objProcess in colProcess
	objDocument.Writeln objProcess.Name & "<BR>"
Next

'**** Prompt, verify, and terminate process ****
Do Until strVerify = vbyes
strProcessKill = InputBox("Enter the name of the process to terminate on " & strComputer & "." & vbcrlf & "Either copy and paste the process from the list on the left or type in the complete process name." & vbcrlf & vbcrlf & vbcrlf & "Case Sensitive" & vbcrlf & " (i.e. notepad.exe or MYINFO.EXE)", strTitle)
If IsEmpty(strProcessKill) Then 
	objExplorer.Quit
	WScript.Quit
End If
strProcessKill = Trim(strProcessKill)

Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set colProcess = objWMIService.ExecQuery ("Select * from Win32_Process")
For Each objProcess in colProcess
	If strProcessKill = objProcess.Name Then
		strVerify = MsgBox("Are you sure you want to terminate process " & chr(39) & strProcessKill & Chr(39) & "?", vbyesno, strTitle)
		If strVerify = vbyes Then
			objShell.Run(strPSKILL & " \\" & strComputer & " " & strProcessKill),0,True
			MsgBox "Process " & Chr(39) & strProcessKill & Chr(39) & " was successfully terminated on " & strComputer, vbOKOnly, strTitle
			Exit Do
		End If
	End If
Next
Loop
objExplorer.Quit

WScript.Quit
