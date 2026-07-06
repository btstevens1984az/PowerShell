# Purpose: Get-HPCADeviceSynopsisForHostname — HP Radia client automation and satellite servers.
$plainpassword = 'HPCL13nt@dM1n'
$securepassword = $plainpassword | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "HPCAAPP",$securepassword
Function Get-HPCADeviceSynopsisForHostname {
param( 
  [Parameter(Position=0,ValueFromPipeline=$true)] 
  [Alias("CN","Computer")] 
  [String[]]$ComputerName="$env:COMPUTERNAME" 
  ) 
Read-SqlTableData -ServerInstance "114.148.18.125" -DatabaseName "RCA_CORE" -SchemaName "dbo" -TableName "DeviceSynopsis" -ConnectionTimeout 30 -Credential $cred | Where-Object -Property device_id -eq $ComputerName | fl -Force
}
