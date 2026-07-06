# Purpose: InformationalOutputStream — PowerShell automation.
###############################################################################
# Informational output stream
# New output stream
Write-Information -MessageData "This is a Information Message" -Tags "Information" -InformationAction Continue 

# Redirection of new Stream (6 = Information)
Write-Information -MessageData "Redirect me..." -Tags "Information" 6> $DemoPath\InfoStream.txt

#Can now redirect write-host
Write-Host "test" 6> c:\temp\test.txt

$InformationPreference

#new Common Parameters
Write-Host "Output is still sent to the host but also the information output stream" -InformationVariable var 
Write-Information "you won't see this" 
Write-Information "you will now see this" -InformationAction Continue 