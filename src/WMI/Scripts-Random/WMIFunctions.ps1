# Purpose: WMIFunctions — PowerShell automation.


Function PingComputer
{
	#If status code is 0 then the ping is successful
	param($comp=$(Throw "Must specify an address to ping"))
	$status = $false
	$numTries = 1
	Do
	{$result = Get-WmiObject Win32_pingstatus -Filter "address ='$comp'"
	 $status=$result.statuscode
	 $numTries++
	}until ($status -eq 0 -or $numTries -gt 2)
	$status #return status code
}

Function GetDefaultUserName
{
	param($computer=$(Throw "Must specify a computername"))
	$HKLM = 2147483650
	$regKey="SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
	$regValueName ="DefaultUsername"
	$wmireg = [WMICLASS]"\\$computer\root\default:stdregprov"
	$reg = $wmireg.GetStringValue($HKLM,$regKey,$regValueName)
	if ($reg.ReturnValue -eq 0)
	{$reg.sValue}
	else
	{"error retrieving last logged on user"}

}

Function CheckHotFix
{
	#returns hotfix object if found or nothing if not found
	#hotfixid='KB944043-v3'
	param([string]$computer=".",[string]$hotfixID=$(Throw "Must specify a hotfixID"))
	$WmiResult = Get-WmiObject -class Win32_QuickFixEngineering -Filter "hotfixid='$hotfixid'" -ComputerName $computer
	$WmiResult
}


Function TestWMI
{
#returns true if successful and false if not
param([string]$comp=".")
trap
{
#WMI error
 #$Error.Clear()
 Write-Host $error
 $false
 continue
}
$result = Get-WmiObject -Query "Select caption from Win32_operatingsystem" -ComputerName $comp
	if ($result)
	{
	$true
	}
	else
	{
	$false
	}

}

Function GetWMIInfo($objComputer)
{	
	$currentUser = $null
	$model = $null
	$Manufacturer = $null
	$comp = $objComputer.name
	$WMIComp = Get-WmiObject Win32_Computersystem -ComputerName $comp
	$lastloggedonUser = GetDefaultUserName $comp
	If ($WMIComp.username) {$currentuser = $WMIComp.username}
	If ($WMIComp.Manufacturer) {$Manufacturer = $WMIComp.Manufacturer}
	If ($WMIComp.model) {$Model = $WMIComp.model}	
	$objComputer | Add-Member -MemberType NoteProperty -Name "CurrentUser" -Value $currentUser
	$objComputer | Add-Member -MemberType NoteProperty -Name "LastLogonUser" -Value $lastloggedonUser
	$objComputer | Add-Member -MemberType NoteProperty -Name "Model" -Value $Model
	$objComputer | Add-Member -MemberType NoteProperty -Name "Manufacturer" -Value $Manufacturer
}