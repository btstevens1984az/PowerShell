# Purpose: UsersInheritance — General-purpose PowerShell utilities.
#So for example, to get a list of all users in the domain who has inheritance off you just need to run:

Get-QADUser -SizeLimit 0 | where {$_.DirectoryEntry.psbase.ObjectSecurity.AreAccessRulesProtected} | select-object sAMAccountName | out-file C:\powershell2\usersInheritancereport2.txt

# Get-QADUser -SizeLimit 10 | where {$_.DirectoryEntry.psbase.ObjectSecurity.AreAccessRulesProtected} | select-object sAMAccountName | Export-csv C:\powershell2\usersInheritanceTest3.CSV

# Fixing with the Set-QADObjectSecurity

# So if you want to fix inheritance for all AD users (caution: you might want to just get the list of the accounts first using the command above to make sure you do not �fix� legitimate exceptions) you just need to pipe the collection into Set-QADObjectSecurity -UnlockInheritance:

# Get-QADUser -SizeLimit 0 | where {$_.DirectoryEntry.psbase.ObjectSecurity.AreAccessRulesProtected} | Set-QADObjectSecurity -UnlockInheritance

# TO RESET inheritance on a single account

#  set-qadobjectsecurity -identity rzorz -unlockinheritance

# select-object name | Export-csv C:\powershell2\usersInheritanceTest.CSV
# select-object NAME, MACADDRESS, @{Label="ComputerName"; Expression={$PC.NAME}} | Export-csv C:\MACADDRS.CSV

# Get-Content c:\names.txt | ForEach-Object { Get-WmiObject -computername $_ -class Win32_OperatingSystem | ForEach-Object { $_.Reboot() } }

# C:\powershell2\usersInheritanceTest.txt

# Get-Content C:\powershell2\usersInheritanceTest.txt | Set-QADObjectSecurity -UnlockInheritance 
# Get-Content C:\powershell2\kerry.txt | Set-QADObjectSecurity -UnlockInheritance 