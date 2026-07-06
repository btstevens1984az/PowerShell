# Purpose: Get-HPCADevicesWithExitcodeNotEqualTo0 — HP Radia client automation and satellite servers.
$plainpassword = 'HPCL13nt@dM1n'
$securepassword = $plainpassword | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "HPCAAPP",$securepassword
Function Get-HPCADevicesWithExitcodeNotEqualTo0 {
Read-SqlTableData -ServerInstance "114.148.18.125" -DatabaseName "RCA_CORE" -SchemaName "dbo" -TableName "DeviceSynopsis" -ConnectionTimeout 30 -Credential $cred | Select-Object -Property device_id,Exitcode,cname,Errormsg,dname | Where-Object -Property Exitcode -NE '0' | Sort-Object -Property ExitCode -Descending | ft -a -w
}