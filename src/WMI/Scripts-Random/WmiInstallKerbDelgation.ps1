# Purpose: WmiInstallKerbDelgation — PowerShell automation.
#JD
#this demo demonstrates using delegation and the [wmiclass] type accelerator
#advanced wmi options are demonstrated as well

Function installAdminPak
{
	#all servers passed in need to be configured for kerberos delegation (i.e. lisbon)
	param($Servers="46.102.135.238") 
	foreach($server in $servers)
	{
		$Wmi =[wmiclass]"\\$server\root\cimv2:win32_product"
		$Wmi.psbase.scope.options.Impersonation = "delegate"
		$Wmi.psbase.Scope.Options.Authority = "kerberos:nwtraders.com\$server"
		$wmiRtn = $Wmi.install("\\78.61.6.96\c$\windows\system32\adminpak.msi")
		if ($wmiRtn.ReturnValue -eq 0)
		{
			Write-host "The Windows Administrative tools were installed successfully on: $server"
		}
		
 	}
}

installadminpak -servers "lisbon"