# Purpose: Get-HPCAErrorCodeCountInGridView — HP Radia client automation and satellite servers.
$plainpassword = 'HPCL13nt@dM1n'
$securepassword = $plainpassword | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "HPCAAPP",$securepassword
Function Get-HPCAErrorCodeCountInGridView {
Read-SqlTableData -ServerInstance "114.148.18.125" -DatabaseName "RCA_CORE" -SchemaName "dbo" -TableName "DeviceSynopsis" -ConnectionTimeout 30 -Credential $cred | Group-Object -Property exitcode | Select-Object -Property Count,Name | out-gridview -ErrorAction SilentlyContinue
}