# Purpose: 1 SqlExport — Network diagnostics, DNS, DHCP, and connectivity.

#region "imports"
	$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition #get directory of the script.
	$Log = $scriptPath + "\script_Error.log" #Where the errors go
	$target_file = $scriptPath + "\CSV\Device_patch_status.csv" #Status log.
    $SqlCommandFile = $scriptPath + "\queries\Device_Patch_status.sql"
#endregion

#region "VARS"
	[string] $hostname = "114.148.18.125"
	#[string] $instacne     = "HPCA_PATCH"
	[string] $db       = "HPCA_PATCH"
	[string] $user     = "hpcaapp"
	[string] $pass     = "HPCL13nt@dM1n"
	[string] $cnnstr   = ("Server={0};Database={1};User ID={2};Password={3}" -f $hostname,$db,$user,$pass)
#endregion


#region "DB Connect"
$sCnn = New-Object System.Data.SqlClient.SqlConnection
$sCnn.ConnectionString = $cnnstr #passing the connection string

$sCmd = New-Object System.Data.SqlClient.SqlCommand
$sCmd.CommandText = (get-content $SqlCommandFile) #"SELECT DISTINCT devicename FROM DeviceConfig"
$sCmd.CommandTimeOut = 240
$sCmd.Connection  = $sCnn
$adapter = new-object System.Data.SqlClient.SqlDataAdapter
$adapter.SelectCommand= $sCmd
$set = New-Object System.Data.DataSet
$adapter.fill($set)
$sCnn.Close()

$set.Tables[0] | Export-Csv $target_file -NoTypeInformation


#endregion

