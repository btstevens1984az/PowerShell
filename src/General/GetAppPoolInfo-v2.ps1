# Purpose: GetAppPoolInfo — General-purpose PowerShell utilities.
#demonstrates specifying PacketPrivacy

#	$ret = $buffer.append(",$($app.)");

#param($computers="localhost")

###$erroractionpreference = "SilentlyContinue"

$err1 = @"

You have to inform at least one computer name.

Sample 1:
		.\GetAppPoolInfo.ps1 localhost

Sample 2:
		.\GetAppPoolInfo.ps1 ServerA ServerB ServerC ServerD

"@;

$err2 = @"
	It was not possible to connect to specified computer.
	Please check computer name specified, dns, user permissions ...
	Details:
"@;

if (!$args)
{
	write-host -ForegroundColor Red $err1;
	exit 0;
}

function funline ($strIN)
{
 $strLine= "=" * $strIn.length;
 Write-Host -ForegroundColor yellow $strIN ;
 Write-Host -ForegroundColor green $strLine;
 Write-Host " ";
}

function funLookup([ref]$StrIN)
{
 switch($strIN.value)
  {
   0   { $strIN.value = "NO ACTION" }
   1   { $strIN.value = "SHUTDOWN" }
  }
}
function BuildHeader()
{
	$buf = New-Object -typeName System.Text.StringBuilder;	
	$ret = $buf.append("Computer,AppPool-Name,Description,");
	$ret = $buf.append("Recycle (in mins),Recycle (in reqs),Recycle (times),Vir Mem Recycle (in Mb),Priv Mem Recycle,");
	$ret = $buf.append("Shutdown WP (in mins),ReqQueueLimit,CPU-Usage (%),CPU-Usage (in mins),CPU-Action,WebGarden,");
	$ret = $buf.append("EnablePing,PingInterval (in secs),Enable-RFP,Failures,Time (in mins), Startup-Limit, Shutdown-Limit,");
	$ret = $buf.append("User-Identity, Password`n");
	$global:header = $buf.ToString();
}

cls

funline("Starting Script GetApplicationPools Settings...");

$bufferFull = New-Object -typeName System.Text.StringBuilder;
BuildHeader;
$ret = $bufferFull.Append($($header));

$credential = Get-Credential -credential user1

foreach ($server in $args)
{

write-host -foregroundcolor cyan "Connecting on computer: $($server) ...";

$query = [WMISearcher] "Select * from IIsApplicationPoolSetting" 
$query.scope.path = "\\$($server)\root\MicrosoftIISv2" 
$query.scope.options.username = $credential.username 
$query.scope.options.password = $credential.GetNetworkCredential().password 
$query.scope.options.Authentication = "PacketPrivacy" 

### $appPools = Get-WmiObject -Namespace root\microsoftiisv2 -class IIsApplicationPoolSetting -computername $server -ErrorVariable errWmi;

$appPools = $query.get() 

### if (!($errWmi[0] -eq $null))
###{
###	write-host -ForegroundColor Red $err2;
###	write-host -ForegroundColor Red $errwmi[0];
###}
###else
###{
 write-host -foregroundcolor cyan " ... connected !";


 Write-host "Found $($appPools.Length) Application Pools.";
 Write-host "`nDumping Application Pools Settings to CSV...";

 $buffer = New-Object -typeName System.Text.StringBuilder;
 

 foreach ($app in $appPools)
 {
	# Server, AppPool Name, and Description
	$ret = $buffer.append($app.__SERVER);
	$ret = $buffer.append(",$($app.name.substring(15))");
	$ret = $buffer.append(",$($app.description)");

	# Recycling Tab 
	$ret = $buffer.append(",$($app.PeriodicRestartTime)");
	$ret = $buffer.append(",$($app.PeriodicRestartRequests)");
	$ret = $buffer.append(",$($app.PeriodicRestartSchedule)");
	$memMb = [int32] $app.PeriodicRestartMemory/1024;
	$ret = $buffer.append(",$($memMb)");
	$memMb = [int32] $app.PeriodicRestartPrivateMemory/1024;
	$ret = $buffer.append(",$($memMb)");

	#Performance Tab
	$ret = $buffer.append(",$($app.IdleTimeout)");
	$ret = $buffer.append(",$($app.AppPoolQueueLength)");
	$tmp = [int32] $app.CPULimit / 1000;
	$ret = $buffer.append(",$($tmp)");
	$ret = $buffer.append(",$($app.CPUResetInterval)");
	$strAction = $app.CPUAction;
	funLookup([ref]$strAction);
	$ret = $buffer.append(",$($strAction)");
	$ret = $buffer.append(",$($app.MaxProcesses)");

	#Heatlh Tab
	$ret = $buffer.append(",$($app.PingingEnabled)");
	$ret = $buffer.append(",$($app.PingInterval)");
	$ret = $buffer.append(",$($app.RapidFailProtection)");
	$ret = $buffer.append(",$($app.RapidFailProtectionMaxCrashes)");
	$ret = $buffer.append(",$($app.RapidFailProtectionInterval)");
	$ret = $buffer.append(",$($app.StartupTimeLimit)");
	$ret = $buffer.append(",$($app.ShutdownTimeLimit)");

	#Identity Tab
	$ret = $buffer.append(",$($app.WAMUserName)");
	$ret = $buffer.append(",$($app.WAMUserPass)`n");
 }

 $ret = $bufferFull.Append( $buffer.ToString() );

 $ret = $buffer.Insert(0, $($header));

 $filename = "$($server).csv";
 Out-File -filepath $($filename) -force -inputobject $buffer.ToString();

 Write-host "... data dumped - file saved: $($filename) `n`n";


###}

}


$filename = "SERVERS-AppPoolSettings.csv";

Write-host "`n`nSAVING DATA FROM ALL SERVERS IN $($filename)...";

Out-File -filepath $($filename) -force -inputobject $bufferFull.ToString();

Write-host "...DONE!";


funline("... script finished!");

