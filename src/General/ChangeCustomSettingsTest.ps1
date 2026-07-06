# Purpose: ChangeCustomSettingsTest - Copy — General-purpose PowerShell utilities.
$LogOutputTrans = $((Get-Date).ToString('yyyyMMdd-hhmm') + "_CopyCustomSettingsTest.txt")
start-transcript -Path "\\75.87.199.36\I$\ControlChange\JobLog\$LogOutputTrans" -IncludeInvocationHeader
$ErrorActionPreference = 'SilentlyContinue'
write-host -foregroundcolor Yellow "Test will not overwrite the CustomSettings file."
Write-Host "Press enter to continue and CTRL-C to exit ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
$computers = gc "C:\tempMDT\ControlChange\FSSservers.txt"
$source = "C:\tempMDT\ControlChange\CustomSettingsTest.ini"
$destination = "MDT\Deploy\Control\"
	foreach ($Computer in $Computers) {
		Copy-Item $source -Destination "\\$computer\$destination" -force
		write-host -foregroundcolor Yellow "$computer Done"
	}
write-host -ForegroundColor Green "All systems processed"
stop-transcript