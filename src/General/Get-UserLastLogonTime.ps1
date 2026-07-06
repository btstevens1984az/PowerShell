# Purpose: Get-UserLastLogonTime — General-purpose PowerShell utilities.
# get last logon time for a user

$hash_lastLogonTimestamp = @{Name="LastLogonTimeStamp";Expression={([datetime]::FromFileTime($_.LastLogonTimeStamp))}}
$hash_pwdLastSet = @{Name="pwdLastSet";Expression={([datetime]::FromFileTime($_.pwdLastSet))}}
 
get-aduser SCCMSUP -properties lastlogontimestamp,pwdLastSet | `
    select samaccountname, $hash_lastLogonTimestamp,$hash_pwdLastSet
	
	get-aduser SCCMSUC -properties lastlogontimestamp,pwdLastSet | `
    select samaccountname, $hash_lastLogonTimestamp,$hash_pwdLastSet
	
	get-aduser SCCMRA -properties lastlogontimestamp,pwdLastSet | `
    select samaccountname, $hash_lastLogonTimestamp,$hash_pwdLastSet
	
	get-aduser SCCMNA -properties lastlogontimestamp,pwdLastSet | `
    select samaccountname, $hash_lastLogonTimestamp,$hash_pwdLastSet
	
	get-aduser SCCMCP -properties lastlogontimestamp,pwdLastSet | `
    select samaccountname, $hash_lastLogonTimestamp,$hash_pwdLastSet