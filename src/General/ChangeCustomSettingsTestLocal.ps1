# Purpose: ChangeCustomSettingsTestLocal — General-purpose PowerShell utilities.
$LogOutputTrans = $((Get-Date).ToString('yyyyMMdd-hhmm') + "_CopyCustomSettingsTest.txt")
start-transcript -Path "C:\tempMDT\ControlChange\JobLog\$LogOutputTrans" -IncludeInvocationHeader
$start= date
$ErrorActionPreference = 'SilentlyContinue'

#test local copy to verify all FSS servers in list get the file

# copies CustomSettings with TEST file name defined as reference

write-host -foregroundcolor Yellow "This is the test script and will not overwrite the CustomCettings file."
#Add-Content "C:\tempMDT\ControlChange\JobLog\$LogOutputTrans" "This is the test script and will not overwrite the CustomCettings file."

# force user to confirm continuing

Write-Host "Press enter to continue and CTRL-C to exit ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

#list of targets - this should include all FSS servers that should get the new CustomSettings.ini file
# $computers = gc "C:\tempMDT\ControlChange\FSSservers.txt"

# really just used in testing. as file name is the same for both 002 or 003

$File2Copy= "CustomSettingsTest.ini"
 write-host "File name is $File2Copy"
# Add-Content "C:\tempMDT\ControlChange\JobLog\$LogOutputTrans" "File name is $File2Copy"

# This is the file you want to copy to the servers in the $computer variable

$source = "C:\tempMDT\ControlChange\CustomSettingsTest.ini"
write-host "Source is $source"
#Add-Content "C:\tempMDT\ControlChange\JobLog\$LogOutputTrans" "Source is $source"

# The destination location you want the file to be copied to production

$destination = "C:\tempMDT\ControlChange\Test\"

write-host "Destination is $destination"
#Add-Content "C:\tempMDT\ControlChange\JobLog\$LogOutputTrans" "Destination is $destination"
#Add-Content "C:\tempMDT\ControlChange\JobLog\$LogOutputTrans" "Copy-Item $source -Destination "$destination" -force"

Copy-Item $source -Destination "$destination" -force
 
write-host -ForegroundColor Green "All systems processed"

$timeCompleted = get-date
write-host "C:\tempMDT\ControlChange\JobLog\$LogOutputTrans" "All systems have completed processing $timeCompleted"
$endjobtime = Dated

write-host "Finished"
stop-transcript