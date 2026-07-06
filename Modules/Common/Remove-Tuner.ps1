# Purpose: Remove-Tuner — Reusable PowerShell function libraries.
Function Remove-Tuner {
#modify servers path to dir with list of systems to run against...
#modify logoutput to new desired name..
$servers = get-content "U:\Functions\RemoveTuner8v2.txt"
$logOutputName = "TunerRemoval-test-XXX.txt"
# set variable to call in wmi results $classkey= get-wmiobject -Class Win32_Product -Filter "name='Marimba'"

 foreach($serverItem in $servers) {

 $classkey= get-wmiobject -Class Win32_Product -Filter "name='Marimba'" -ComputerName $ServerItem 
 write-host -ForegroundColor Green ClassKey value is   $classkey
	$TestPathDir = test-path "\\$ServerItem\c$\Program Files (x86)\Marimba\Castanet Tuner"
			
			If ($TestPathDir -eq $True) {
				write-host -ForegroundColor Green Windows Tuner directory exists on $serveritem
				Add-Content "U:\Functions\$LogOutputName" "\\$ServerItem\c$\Program Files (x86)\Marimba\Castanet Tuner was found"
			
			$TunerFileInfo = (get-item "\\$ServerItem\c$\Program Files (x86)\Marimba\Castanet Tuner\tuner.exe").VersionInfo.FileVersion
			
				write-host -ForegroundColor Green "$serverItem Tuner.exe file version is " $TunerFileInfo
				Add-Content "U:\Functions\$LogOutputName" "$serverItem Tuner.exe file version is  $TunerFileInfo"
				#$clsid = gwmi win32_product -computername "$serverItem" | where {$_ -match "marimba"}
				#foreach($cls in $clsid) {$cls.uninstall()}
						
						$classkey.uninstall()	
						
			If ($TestPathDir -ne $True) {
			write-host -ForegroundColor Red Windows Tuner directory does not exist on $serveritem
				Add-Content "U:\Functions\$LogOutputName" "\\$ServerItem\c$\Program Files (x86)\Marimba\Castanet Tuner was Not found"
				# msiexec http://itweb/tuner/CHWTunerx86_MDTBUILD_20170423.exe /q
				}
			# test for tuner version after uninstall... 						
 $TestPathDirCheck = test-path "\\$ServerItem\c$\Program Files (x86)\Marimba\Castanet Tuner\tuner.exe"
		Write-Host "Tuner.exe found in path  - $TestPathDirCheck"
           If ($TestPathDirCheck -eq $True) {
				write-host -ForegroundColor Green Windows Tuner directory exists on $serveritem
				Add-Content "U:\Functions\$LogOutputName" "\\$ServerItem\c$\Program Files (x86)\Marimba\Castanet Tuner found after UNinstall"
			$TunerFileInfo2 = (get-item "\\$ServerItem\c$\Program Files (x86)\Marimba\Castanet Tuner\tuner.exe").VersionInfo.FileVersion
			
				write-host -ForegroundColor Green "$serverItem Tuner.exe file version is " $TunerFileInfo2
			}
	}
}
write-host "DONE"
}