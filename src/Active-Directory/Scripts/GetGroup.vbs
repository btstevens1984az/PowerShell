'call this script using wscript from a command line interface
'getgroup.vbs group1
'where group1 is the SAMAccount of the SOURCE group
 

Dim arrSourceMembers()
Dim sSourceGroup
Dim sTargetGroup
Dim strSourceGroupDN
Dim strTargetGroupDN
 

'Set objArgs = WScript.Arguments
'if objArgs.Count <> 1 Then
'wscript.echo "Incorrect # of Arguments"
'wscript.echo VbCrLf
'wscript.quit
'Else
'End If
 
Set oFSO = CreateObject("Scripting.FileSystemObject")

'****  Create the Output TXT file on your local drive that will be used for output
Set oWriteFile = oFSO.CreateTextFile("C:\Temp\FileName.txt")

'*** Type in the name of the group that you want the members of
sSourceGroup = "AD Group Name"

'sSourceGroup = objArgs(0)
 
strSourceGroupDN = GetDnFromName(sSourceGroup)
 
'step 1 Enummerate Source Group Membership
 
EnumSourceGroup
 
y = UBOUND(arrSourceMembers)
wscript.echo y + 1 & " members in the group"
 
oWriteFile.Close
msgbox "press any key to continue"
wscript.quit
 
 
 
 
 
Sub EnumSourceGroup
 
On Error Resume Next
Err.Clear
 
Set objSourceGroup = GetObject("LDAP://" & strSourceGroupDN)
 
if err.number <> 0 Then
wscript.echo "Error in Sub EnumSourceGroup - Get Group " & Err.Number & " " & Err.Description
wscript.quit
Else
End If
 
x = 0
For each objMember in objSourceGroup.Members
ReDim Preserve arrSourceMembers(x)
arrSourceMembers(x) = objMember.AdsPath
 
Set objUser = GetObject(objMember.AdsPath)
strOffice = objUser.Get("physicalDeliveryOfficeName")
if err.number = -2147463155 Then
strOffice = ""
err.clear
Else
End If
 
'strSAM = objUser.Get("SamAccountName")
strSAM = "EXAMPLE.COM\" & objUser.Get("SamAccountName")
if err.number = -2147463155 Then
strName = ""
err.clear
Else
End If
 
strName = objUser.Get("Name")
if err.number = -2147463155 Then
strName = ""
err.clear
Else
End If
 
strLastName = objUser.Get("Sn")
if err.number = -2147463155 Then
strLastName = ""
err.clear
Else
End If
 
strFirstName = objUser.Get("givenName")
if err.number = -2147463155 Then
strFirstName = ""
err.clear
Else
End If
 
strDept = objUser.Get("department")
if err.number = -2147463155 Then
strDept = ""
err.clear
Else
End If
 
strMail = objUser.Get("mail")
if err.number = -2147463155 Then
strMail = ""
err.clear
Else
End If
 
'oWriteFile.WriteLine objMember.AdsPath & vbTab & strOffice
'WScript.Echo objMember.AdsPath
 
WScript.Echo strSAM & vbTab & strName & vbTab & strLastName & vbTab & strFirstName & vbTab & strOffice & vbTab & strDept & vbTab & strMail
oWriteFile.WriteLine strSAM & vbTab & strName & vbTab & strLastName & vbTab & strFirstName & vbTab & strOffice & vbTab & strDept & vbTab & strMail
 
'oWriteFile.WriteLine objUser.FullName
'WScript.Echo objMember.AdsPath & vbTab & strOffice
 
Set objUser = Nothing
x = x + 1
Next
 
'if err.number <> 0 Then
'wscript.echo "Error in Sub EnumSourceGroup Get Membership " & Err.Number & " " & Err.Description
'wscript.quit
'Else
'End If
 
End Sub
 
 
 
Function GetDnFromName(strInputName)
 
strADsPath = "LDAP://DC=CHW,DC=ORG,DC=com"
strBase = "<" & strADsPath & ">"
strFilter = "(&(objectCategory=group)(sAMAccountName="&strInputName&"))"
strAttributes = "distinguishedName"
strScope = "subtree"
 
set objADOConnection = CreateObject("ADODB.Connection")
objADOConnection.Open "Provider=ADsDSOObject;"
 
set objADOCommand = CreateObject("ADODB.Command")
objADOCommand.ActiveConnection = objADOConnection
 
objADOCommand.CommandText = strBase & ";" & strFilter & ";" & strAttributes & ";" & strScope
objADOCommand.Properties("Page Size") = 20
 
set objADORecordset = objADOCommand.execute
 
if objADORecordset.EOF Then
msgbox "No Records Found - Cannot Find Group"
wscript.quit
else
end if
 
count = 0
 
While Not objADORecordset.EOF
 
count = count + 1
if count <> 1 Then
msgbox "More Than One Record Returned - Cannot Find Group"
wscript.quit
else
end if
 
strUSRPath = objADORecordSet.Fields("distinguishedName")
GetDnFromName = strUSRPath
 
objADORecordset.MoveNext
 
Wend
 
set objADOConnection = Nothing
set objADOCommand = Nothing
set objADORecordset = Nothing
 
End Function
 

 
