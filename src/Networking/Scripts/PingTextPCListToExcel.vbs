'*******************************************************************
'Script for pinging a list of computers in a text file
'Brandon Stevens
'Created 01/21/2018
'*******************************************************************

Set objFSO = CreateObject("Scripting.FileSystemObject")
strTitle = "Ping a list of computers in a text file"

'**** Prompts the user for the file path and text file name ****
Do Until strPath = True
InputPathFile = InputBox ("Enter the full path and the text file name that contains the list of computers that you would like to ping." & vbcrlf & vbcrlf & "For example:" & vbcrlf & "c:\computers.txt or \\29.222.253.230\computers.txt", strTitle)
If IsEmpty(InputPathFile) Then WScript.Quit
InputPathFile = Trim(Replace(InputPathFile, Chr(34),""))
If objFSO.FileExists(InputPathFile) Then
	strPath = True
Else
	BadPathFile = MsgBox ("File path " & InputPathFile & " does not exist." & vbcrlf & "Please verify and re-enter the file path.", vbOKCancel, strTitle)
	If BadPathFile = vbCancel Then WScript.Quit
	strInput = False
End If
Loop

'**** Opens Excel and populates a header ****
Set objExcel = CreateObject("Excel.Application")
objExcel.Visible = True
objExcel.Workbooks.Add
intRow = 2

objExcel.Cells(1, 1).Value = "Computer Name"
objExcel.Cells(1, 2).Value = "On/Off Line"
objExcel.Cells(1, 3).Value = "Ping Details"
objExcel.Cells(1, 4).Value = "Ping Date/Time"

'**** Pings each computer and records the results ****
Set InputFile = objFSO.OpenTextFile(InputPathFile)

Do While Not (InputFile.atEndOfStream)
strComputer = InputFile.ReadLine
strComputer = Trim(strComputer)

objExcel.Cells(intRow, 1).Value = strComputer

Set objShell = CreateObject("WScript.Shell")

strCommand = "%comspec% /c ping -n 1 " & strComputer
Set objExecObject = objShell.Exec(strCommand)
strText = objExecObject.StdOut.ReadAll
If InStr(strText, "TTL=") > 0 Then
	objExcel.Cells(intRow, 2).Value = "On Line"
	objExcel.Cells(intRow, 3).Value = "pinged " & strIP
Elseif InStr(strText, "unreachable.") > 0 Then
	objExcel.Cells(intRow, 2).Value = "On Line"
	objExcel.Cells(intRow, 3).Value = "destination host unreachable"
ElseIf InStr(strText, "could not find host") > 0 Then
	objExcel.Cells(intRow, 2).Value = "Off Line"
	objExcel.Cells(intRow, 3).Value = "could not find host"
Elseif InStr(strText, "Request timed out.") > 0 Then
	objExcel.Cells(intRow, 2).Value = "Off Line"
	objExcel.Cells(intRow, 3).Value = "request timed out"
Else
	objExcel.Cells(intRow, 2).Value = "?"
	objExcel.Cells(intRow, 3).Value = "details unknown"
End If

objExcel.Cells(intRow, 4).Value = NOW

intRow = intRow + 1
objExcel.Cells.EntireColumn.AutoFit
Loop

objExcel.Range("A1:D1").Select
objExcel.Selection.Interior.ColorIndex = 19
objExcel.Selection.Font.ColorIndex = 11
objExcel.Selection.Font.Bold = True
objExcel.Cells.EntireColumn.AutoFit

Function strIP
	strLeft = InStr(strText,Chr(91))
	strRight = InStr(strText,Chr(93))
	strLEN = strRight - strLeft
	strIP = (Mid(strText,strLeft + 1,strLEN - 1))
End Function
WScript.Quit
