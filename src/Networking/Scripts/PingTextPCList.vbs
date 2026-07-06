'*******************************************************************
'Script for pinging a list of computers in a text file
'Brandon Stevens
'Created 01/21/2018
'*******************************************************************

Const ForReading = 1
Const ForWriting = 2
Const ForAppending = 8

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objShell = CreateObject("WScript.Shell")

'**** Prompts the user for the file path and text file name ****
strTitle = "Ping a list of computers in a text file"
Do Until strInput = True
InputFile = InputBox ("Enter the full path and the name of the text file with the list of computer names you would like to ping" & vbcrlf & vbcrlf & vbcrlf & vbcrlf & "For example: c:\computers.txt or \\29.222.253.230\computers.txt", strTitle)
If IsEmpty(InputFile) Then WScript.Quit
InputFile = Trim(Replace(InputFile, Chr(34),""))
If objFSO.FileExists(InputFile) Then
	Set objFile = objFSO.GetFile(InputFile)
	NewFile = MsgBox ("A new text file with the ping results will be created at this path " & Replace(objFSO.GetAbsolutePathName(objFile), ".txt", "_pinged.txt.") & vbcrlf & "When the script is done the new text file will be opened." & vbcrlf & vbcrlf & "Please click 'OK' to start pinging or 'Cancel' to end.", vbOKCancel, strTitle)
	If NewFile = vbCancel Then WScript.Quit
	OutputFile = Replace(objFSO.GetFileName(objFile), ".txt", "_pinged.txt")
	'**** Creates a new text file based on the existing file name ****
	objFSO.CreateTextFile objFSO.GetParentFolderName(objFile) & "\" & OutputFile
	PingedFile = objFSO.GetParentFolderName(objFile) & "\" & OutputFile
	strInput = True
Else
	BadPath = MsgBox ("File path " & InputFile & " does not exist." & vbcrlf & "Please verify and re-enter the file path.", vbOKCancel, strTitle)
	If BadPath = vbCancel Then WScript.Quit
	strInput = False
End If
Loop

Set objTextFile = objFSO.OpenTextFile(objFile, ForReading)
strComputers = objTextFile.ReadAll
objTextFile.Close

'**** Remove any unecessary blank lines from text file ****
intLength = Len(strComputers)
strEnd = Right(strComputers, 2)

If strEnd = vbCrLf Then
    strComputers = Left(strComputers, intLength - 2)
    Set objTextFile = objFSO.OpenTextFile(objFile, ForWriting)
    objTextFile.Write strComputers
    objTextFile.Close
End If
Set intLength = Nothing

arrComputers = Split(strComputers, vbCrLf)

'**** Use comspec to ping each computer, detect ping results, and write results to new file ****
For Each strComputer In arrComputers
	strComputer = Trim(strComputer)
	strCommand = "%comspec% /c ping -n 1 " & strComputer
    Set objExecObject = objShell.Exec(strCommand)
    strText = objExecObject.StdOut.ReadAll
    If InStr(strText, "TTL=") > 0 Then
 		strEqual()
 		Set objFile = objFSO.OpenTextFile(PingedFile, ForAppending)
 		objFile.WriteLine strComputer & "pinged succesfully.            " & Now
 		objFile.Close
    Elseif InStr(strText, "unreachable") > 0 Then
    	strEqual()
 		Set objFile = objFSO.OpenTextFile(PingedFile, ForAppending)
 		objFile.WriteLine strComputer & "destination host unreachable.  " & NOW
 		objFile.Close
    Elseif InStr(strText, "could not find host") > 0 Then
     	strEqual()
 		Set objFile = objFSO.OpenTextFile(PingedFile, ForAppending)
 		objFile.WriteLine strComputer & "could not find host.           " & NOW 
 		objFile.Close
    Elseif InStr(strText, "Request timed out.") > 0 Then
 		strEqual()
		Set objFile = objFSO.OpenTextFile(PingedFile, ForAppending)
 		objFile.WriteLine strComputer & "request timed out.             " & NOW
 		objFile.Close
	Else
 		strEqual()
 		Set objFile = objFSO.OpenTextFile(PingedFile, ForAppending)
 		objFile.WriteLine strComputer & "status unknown.                " & NOW
 		objFile.Close
    End If
Next

'**** Provides equal spacing for the computer names ****
Function strEqual()
	intLength = Len(strComputer)
	intSpaces = 17 - intLength
	For i = 1 To intSpaces
		strComputer = strComputer & " "
	Next
End Function

'**** Opens the new text file with the ping results ****
objShell.Run PingedFile
WScript.Quit
