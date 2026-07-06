'InstalledPrograms.vbs - Lists installed software shown in Registry Uninstall key
'© Bill James - wgjames@mvps.org - 19/Sep/2003 19:51

'This script should run on Windows 2000 and Windows XP as is, and on
'Windows 9X and NT where WMI and current scripting engine are installed.

'Capability to probe a remote computer only available on NT to NT type
'Operating Systems, and only if the local computer is logged in with the
'same ID and PW as the remoted computer.

'Output is to tab delimited text file which can be imported to newer
'versions of Excel and converted to a spreadsheet.

'GetAddRemove Function based on script posted by Torgeir Bakken
'Date: Wed, 17 Sep 2003 21:06:44 +0200
'From: "Torgeir Bakken (MVP)"
'Subject: Re: Track installed software, patches and plugins using WMI
'Newsgroups: microsoft.public.win32.programmer.wmi
Option Explicit

Dim sTitle
sTitle = "InstalledPrograms.vbs by Bill James"
Dim StrComputer
strComputer = InputBox("Enter I.P. or name of computer to check for " & _
                       "installed software (leave blank to check " & _
                       "local system)." & vbcrlf & vbcrlf & "Remote " & _
                       "checking only from NT type OS to NT type OS " & _
                       "with same Admin level UID & PW", sTitle)
If IsEmpty(strComputer) Then WScript.Quit
strComputer = Trim(strComputer)
If strComputer = "" Then strComputer = "."

'Wscript.Echo GetAddRemove(strComputer)

Dim sCompName : sCompName = GetProbedID(StrComputer)

Dim sFileName
sFileName = sCompName & "_" & GetDTFileName() & "_Software.txt"

Dim s : s = GetAddRemove(strComputer)

If WriteFile(s, sFileName) Then
    'optional prompt for display
  If MsgBox("Finished processing.  Results saved to " & sFileName & _
            vbcrlf & vbcrlf & "Do you want to view the results now?", _
            4 + 32, sTitle) = 6 Then
    WScript.CreateObject("WScript.Shell").Run sFileName, 9
  End If
  If MsgBox("Would you like to view the contents of the C drive?", _
  			4 + 32, sTitle) = 6 Then
    WScript.CreateObject("WScript.Shell").Run Chr(34) & "\\" & strComputer & "\C$" & Chr(34)
  End If
End If

Function GetAddRemove(sComp)
  'Function credit to Torgeir Bakken
  Dim cnt, oReg, sBaseKey, iRC, aSubKeys
  Const HKLM = &H80000002 'HKEY_LOCAL_MACHINE
  Set oReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & _
              sComp & "/root/default:StdRegProv")
  sBaseKey = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"
  iRC = oReg.EnumKey(HKLM, sBaseKey, aSubKeys)

  Dim sKey, sValue, sTmp, sVersion, sDateValue, sYr, sMth, sDay

  For Each sKey In aSubKeys
    iRC = oReg.GetStringValue(HKLM, sBaseKey & sKey, "DisplayName", sValue)
    If iRC <> 0 Then
      oReg.GetStringValue HKLM, sBaseKey & sKey, "QuietDisplayName", sValue
    End If
    If sValue <> "" Then
      iRC = oReg.GetStringValue(HKLM, sBaseKey & sKey, _
                                "DisplayVersion", sVersion)
      If sVersion <> "" Then
        sValue = sValue & vbTab & "Ver: " & sVersion
      Else
        sValue = sValue & vbTab 
      End If
      iRC = oReg.GetStringValue(HKLM, sBaseKey & sKey, _
                                "InstallDate", sDateValue)
      If sDateValue <> "" Then
        sYr =  Left(sDateValue, 4)
        sMth = Mid(sDateValue, 5, 2)
        sDay = Right(sDateValue, 2)
        'some Registry entries have improper date format
        On Error Resume Next 
        sDateValue = DateSerial(sYr, sMth, sDay)
        On Error GoTo 0
        If sdateValue <> "" Then
          sValue = sValue & vbTab & "Installed: " & sDateValue
        End If
      End If
      sTmp = sTmp & sValue & vbcrlf
    cnt = cnt + 1
    End If
  Next
  sTmp = BubbleSort(sTmp)
  GetAddRemove = "INSTALLED SOFTWARE (" & cnt & ") - " & sCompName & _
                 " - " & Now() & vbcrlf & vbcrlf & sTmp 
End Function

Function BubbleSort(sTmp)
  Dim aTmp, i, j, temp
  aTmp = Split(sTmp, vbcrlf)  
  For i = UBound(aTmp) - 1 To 0 Step -1
    For j = 0 to i - 1
      If LCase(aTmp(j)) > LCase(aTmp(j+1)) Then
        temp = aTmp(j + 1)
        aTmp(j + 1) = aTmp(j)
        aTmp(j) = temp
      End if
    Next
  Next
  BubbleSort = Join(aTmp, vbcrlf)
End Function

Function GetProbedID(sComp)
  Dim objWMIService, colItems, objItem
  Set objWMIService = GetObject("winmgmts:\\" & sComp & "\root\cimv2")
  Set colItems = objWMIService.ExecQuery("Select SystemName from " & _
                                         "Win32_NetworkAdapter",,48)
  For Each objItem in colItems
    GetProbedID = objItem.SystemName
  Next
End Function

Function GetDTFileName()
  dim sNow, sMth, sDay, sYr, sHr, sMin, sSec
  sNow = Now
  sMth = Right("0" & Month(sNow), 2)
  sDay = Right("0" & Day(sNow), 2)
  sYr = Right("00" & Year(sNow), 4)
  sHr = Right("0" & Hour(sNow), 2)
  sMin = Right("0" & Minute(sNow), 2)
  sSec = Right("0" & Second(sNow), 2)
  GetDTFileName = sMth & sDay & sYr & "_" & sHr & sMin & sSec
End Function

Function WriteFile(sData, sFileName)
  Dim fso, OutFile, bWrite
  bWrite = True
  Set fso = CreateObject("Scripting.FileSystemObject")
  On Error Resume Next
  Set OutFile = fso.OpenTextFile(sFileName, 2, True)
  'Possibly need a prompt to close the file and one recursion attempt.
  If Err = 70 Then
    Wscript.Echo "Could not write to file " & sFileName & ", results " & _
                 "not saved." & vbcrlf & vbcrlf & "This is probably " & _
                 "because the file is already open."
    bWrite = False
  ElseIf Err Then
    WScript.Echo err & vbcrlf & err.description
    bWrite = False
  End If
  On Error GoTo 0
  If bWrite Then
    OutFile.WriteLine(sData)
    OutFile.Close
  End If
  Set fso = Nothing
  Set OutFile = Nothing
  WriteFile = bWrite
End Function
