# Purpose: move60days — General-purpose PowerShell utilities.
# Start of the script
# Set the date to be used as a limit - in this example: 90 days earlier than the current date
$old = (Get-Date).AddDays(-60)
# Get the list of computers with the date earlier than this date
Get-QADComputer -IncludedProperties pwdLastSet -SizeLimit 0 
where { $_.pwdLastSet -le $old }
# Move such computers to another OU
Get-QADComputer -IncludedProperties pwdLastSet -SizeLimit 0 
where { $_.pwdLastSet -le $old } 
Move-QADObject -to 108.45.123.69/Oldcomputers 
# End of the script 