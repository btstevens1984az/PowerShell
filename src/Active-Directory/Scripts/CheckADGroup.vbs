'==========================================================================
' NAME: Check AD Group Membership
' AUTHOR: Brandon Stevens
' DATE  : 01/21/2018
' COMMENT: Checks to see if current logged on user is part of the HPCA_Patch* group
'==========================================================================
On Error Resume Next

Set WshNet = WScript.CreateObject("WScript.Network")
Set WshShell = WScript.CreateObject("WScript.Shell")
Set objFSO = wscript.CreateObject("Scripting.FileSystemObject")

'-----------------------------------ADSI information for user and Computer
Set objSysInfo = CreateObject("ADSystemInfo")

strUserDN = objSysInfo.UserName
'strComputerDN = objSysInfo.ComputerName
'WScript.Echo strUserDN

set objUser = GetObject("LDAP://" & strUserDN)		'Grab user's membership

colUserGroups = objUser.MemberOf
'-------------------------------------

for each group in objUser.MemberOf			'This section is to clean up group names 
	colGroupname = split(group,",")			'Removes CN= and everything after "," from the name

	Groupname = colGroupname(0)

	splGroupnm = Split(Groupname,"=")

	Groupsplit = splGroupnm(1)
	'WScript.Echo groupsplit
	If (Groupsplit) = "HPCA_Patch*" Then
		strMsg = "1"
	End If
Next

If strMsg = "1" Then
	strMedifaxgrp = "HPCA_Patch*: YES"
Else
	strMedifaxgrp = "HPCA_Patch*: NO"
End If

LogFile
'************************************************************************
'***Log File
'************************************************************************
Sub LogFile
	Set objFile = objFSO.OpenTextFile("\\29.222.253.230\HPCAPatchADGroup.log",8)
	objFile.WriteLine Now & vbTab & WshNet.ComputerName & vbTab & WshNet.UserName & vbTab & strMedifaxgrp
	objFile.Close
End Sub
