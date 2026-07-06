# Purpose: UsersAddColl — General-purpose PowerShell utilities.
$Server = "114.148.18.125"
$SiteCode = "BP1"
$UserList = "c:\sccmtest\users.txt"
$ColName = "UserSystems"
$ColID = "BP100AE0"
##Don't edit below here##
 
$Namespace = "root\SMS\site_$SiteCode" 
$strQuery = "Select CollectionID from SMS_Collection where Name like '$ColName'"
# $ColID = (Get-WmiObject -Query $strQuery -Namespace $NameSpace -ComputerName $Server).CollectionID
if ($ColID -ne $null) {
	Get-Content $UserList | ForEach-Object {
		$Username = $_
		# $Username = $Username.replace("\","_")
		$strQuery = "Select ResourceID from SMS_R_User where UniqueUserName like '$UserName'"
		$ResourceID = (Get-WmiObject -Query $strQuery -Namespace $Namespace -ComputerName $Server).ResourceID
		if ($ResourceID -ne $null) {
			$Collection=[WMI]"\\$($Server)\$($Namespace):SMS_Collection.CollectionID='$ColID'"
			$RuleClass = [wmiclass]"\\$($Server)\$($NameSpace):SMS_CollectionRuleDirect"
			$newRule = $ruleClass.CreateInstance()
			$newRule.RuleName = $RuleName
			$newRule.ResourceClassName = "SMS_R_User"
			$newRule.ResourceID = $ResourceID
			$Collection.AddMembershipRule($newRule)
		}
	}
}

 