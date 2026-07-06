# Purpose: ReadHostSecureStringQueryWmi — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 6/20/2009
#
# KEYWORDS: Read-Host, SecureString, psCredential,
# Get-WmiObject
# COMMENTS: This script uses the Read-Host cmdlet to
# prompt for a password. It uses the -asSecureString parameter
# to cause the password to be encrypted as a secureString.
# The -credential parameter of the Get-WmiObject cmdlet
# uses a pscredential object. We create a pscredential object
# by using the new-object .NET Framework class and using 
# system.management.automation.pscredential while passing
# the string for the username and the securestring for the password
#
# Windows PowerShell Best Practices chapter 12
# ------------------------------------------------------------------------

$user = "Nwtraders\administrator"
$password = Read-Host -prompt "Enter your password" -asSecureString
$credential = new-object system.management.automation.pscredential $user,$password
Get-WmiObject -class Win32_Bios -Computername 157.217.58.110 -Credential $credential