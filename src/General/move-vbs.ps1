# Purpose: move-vbs — General-purpose PowerShell utilities.
'This script is designed to find inactive computer accounts in specified domain.
'Once it found inactive computer accounts, script will move it into a specified OU.
'Also,if script find an active account in specified OU, it will be moved back to Computers comtainer.
'The "Inactive" condition is based on "PwdLastChange" properity of computer object.
'Member computer(s)  will change it's password ( for computer account, not user.) every 30 days by default,
'except administrator(s) disable this function. 
'If you did, don't use this script to clear inactive computer accounts in your AD domain. 




Option Explicit
On Error Resume Next
Const ADS_SCOPE_SUBTREE = 2
Dim objConnection,objCommand,objRecordSet,objNewOU,objComputer,objOriComputer
Dim strDomain
Dim strDestOU
Dim intConfirm
Dim intDuration
strDomain="DC=example,DC=local"		'Provide your domain name here
strDestOU="OU=Computers Inactive"		'Provide destination OU here. This OU must exist when your run this script.
intDuration = 45				'Default password reset interval is 30 days. 45 days is author's suggestion.		

Set objConnection = CreateObject("ADODB.Connection")
Set objCommand =   CreateObject("ADODB.Command")
objConnection.Provider = "ADsDSOObject"
objConnection.Open "Active Directory Provider"

Set objCOmmand.ActiveConnection = objConnection
objCommand.CommandText = "Select Name,DistinguishedName from 'LDAP://" & strDomain & _
        "' where objectClass='computer'" 
objCommand.Properties("Page Size") = 6000
objCommand.Properties("Timeout") = 30
objCommand.Properties("Searchscope") = ADS_SCOPE_SUBTREE 
objCommand.Properties("Cache Results") = False

Set objRecordSet = objCommand.Execute
'Error occurs here means domain connection failed.
If Err.Number <> 0 Then Wscript.Quit


Set objNewOU = GetObject("LDAP://" & strDestOU & "," & strDomain)
'Error occurs here means destination OU not exist.
If Err.Number <> 0 Then Wscript.Quit

Set objOriComputer = GetObject("LDAP://CN=Computers," & strDomain)


objRecordSet.MoveFirst
Dim dtmValue,intDateDiff,intSuccessCount,intErrorCount,intNotMoveCount,intMoveBack,objMoveComputer
intSuccessCount = 0
intErrorCount = 0
intNotMoveCount = 0
intMoveBack = 0

Do While not objRecordSet.EOF
	Set objComputer = GetObject("LDAP://" & objRecordSet.Fields("DistinguishedName").Value)
	dtmValue = CDate(objComputer.PasswordLastChanged)
	
	
	
	intDateDiff=CInt(Now - dtmValue)

	If CInt(intDateDiff) > intDuration  Then 
		If InStr(UCase(objRecordSet.Fields("DistinguishedName").Value),UCase(strDestOU) & ",") = 0 Then
			Set objMoveComputer = objNewOU.MoveHere _
	    			("LDAP://" & objRecordSet.Fields("DistinguishedName").Value,"CN=" &_
	    			 objRecordSet.Fields("Name").Value)
			If Err.Number = 0 Then 
				intSuccessCount = intSuccessCount + 1
			Else
	    			
	    			intErrorCount = intErrorCount + 1
	    		End If
	    	Else
	    		'The computer has be moved to destination OU before. 
	    		intNotMoveCount = intNotMoveCount + 1
	    	End If
	Else
		'Move the computer back to original Computers container if it is a active account.
		If InStr(UCase(objRecordSet.Fields("DistinguishedName").Value),UCase(strDestOU) & ",") <> 0 Then
	    		Set objMoveComputer = objOriComputer.MoveHere _
	    			("LDAP://" & objRecordSet.Fields("DistinguishedName").Value,"CN=" &_
	    			 objRecordSet.Fields("Name").Value)
	    		
	    		If Err.Number = 0 Then
	    			
	    			intMoveBack = intMoveBack +1
	    		Else
	    			
	    			intErrorCount = intErrorCount + 1
	    			
	    		End If
	    	End If
	    	
	End If
    
    objRecordSet.MoveNext
    Err.Clear
    
Loop

Wscript.Echo "Executive results:" & Chr(13) &_
		intSuccessCount & " computer(s) moved to specified OU, " & intErrorCount & " computer(s) Failed. " & Chr(13) & _
		intNotMoveCount & " computer(s) already in destination OU, "& intMoveBack & " computer(s) moved back to Computers container."
