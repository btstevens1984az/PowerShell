# Purpose: SetPwdNeverExpires — General-purpose PowerShell utilities.
# powershell2
# Kerry Kreitinger
# change list of users attributes - 
# tried to add -ErrorAction Continue  - but it did not seem to work

get-content �c:\powershell2\users.txt� | Set-QADUser -passwordNeverExpires $false
