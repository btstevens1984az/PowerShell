'==========================================================================
' NAME: DFS Free Space Script 
' AUTHOR: Brandon Stevens
' DATE  : 01/21/2018
'==========================================================================

' On Error Resume Next

Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

Const HARD_DISK = 3

sUtilPath = "\\29.222.253.230\Util\"

strEmail = InputBox("Enter your email address without the @Domain.com" & VbCrLf & VbCrLf & VbCrLf & VbCrLf & "(i.e. John.Doe)","DFS Free Disk Space Report")
If strEmail = "" Then WScript.Quit


strConfirm = MsgBox("The report will be emailed to " & strEmail & "@Domain.com when complete." & VbCrLf & VbCrLf & "Click 'OK' to continue or 'Cancel' to quit.",vbOKCancel,"DFS Free Disk Space Report")
If strConfirm = vbOK Then
Else
	WScript.Quit
End If

Set objExecObject = objShell.Exec("%comspec% /c " & sUtilPath & "dfsutil.exe /root:YOURDOMAIN\dfs-root /view")
Do While Not objExecObject.StdOut.AtEndOfStream
	strOutput = objExecObject.StdOut.ReadLine()
 	If InStr(LCase(strOutput),"swdist$\ent") > 0 Then
		strServer = Mid(strOutput,18,8)
		If strServer = "147.215.172.50" Then
		Else
			Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strServer & "\root\cimv2")
			Set colDisks = objWMIService.ExecQuery("Select * from Win32_LogicalDisk Where DriveType = " & HARD_DISK & "")
			For Each objDisk In colDisks
				If objFSO.FolderExists("\\" & strServer & "\" & Replace(objDisk.DeviceID,":","$") & "\swdist") Or objFSO.FolderExists("\\" & strServer & "\" & Replace(objDisk.DeviceID,":","$") & "\swdist$") or objFSO.FolderExists("\\" & strServer & "\" & Replace(objDisk.DeviceID,":","$") & "\SMS_Software\swdist") Then
					If objDisk.SystemName <> strSystemName Then
						strData = strData & "" & VbCrLf
						strData = strData & "SystemName: " & vbTab &  objDisk.SystemName & VbCrLf
					End If
					strSystemName = objDisk.SystemName
					strData = strData & "DeviceID: "& vbTab &  objDisk.DeviceID & VbCrLf
					sz = objDisk.Size
					Call FormatSize(sz)
					strSize = FormatSize(sz)
					strData = strData & "Total Disk Size: "& vbTab & strSize & VbCrLf
					sz = objDisk.FreeSpace
					Call FormatSize(sz)
					strSize = FormatSize(sz)
					strData = strData & "Free Disk Space: "& vbTab & strSize & vbTab & "(" & FormatPercent(objDisk.FreeSpace / objDisk.Size) & ")" & VbCrLf
' 					If strSpace < .10 Then
' 						strData = strData & "Low Disk Space" & VbCrLf
' 					Else
' 						strData = strData & "Disk Space Good" & VbCrLf
' 					End If
					strData = strData & "\\" & strServer & "\swdist$\ent" & VbCrLf
				End If
			Next
		End If
 	End If
Loop

Call EmailNotification

WScript.Quit

'**** Size Function ****
Function FormatSize(sz)
	Dim labels : Dim range : Dim i
	labels = Array ("byte","KB","MB","GB") 
	For i = 3 to 0 step -1
  		If sz >= (1024^i)-1 Then 
   			range = 1024^i 
   			FormatSize = CStr(FormatNumber(sz/range,2,0,0,-1)) & " " & labels (i)
			Exit For 
  		End If 
 	Next 
End Function

Function EmailNotification
	Set iConf = CreateObject("CDO.Configuration")
	Set iMsg = CreateObject("CDO.Message")
	iConf.Fields.Item("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
	iConf.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "smtp.Domain.com"
	iConf.Fields.Update
	iMsg.Configuration = iConf
	iMsg.To = strEmail & "@Domain.com"
	iMsg.From = "Administrator"
	iMsg.Subject = "DFS Server Low Disk Space Notification " & Now
	iMsg.TextBody = strData
	iMsg.Send
End Function
