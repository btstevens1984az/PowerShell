# Purpose: UsePasswordHashFile — Security auditing and compliance checks.
# -----------------------------------------------------------------------------
# UsePasswordHashFile.ps1
# ed wilson, msft 6/22/2009
# 
# This script uses a password hash file. The password hash file is created:
# Read-Host -Prompt "Enter your password" -AsSecureString |
# ConvertFrom-SecureString >> C:\fso\passwordHash.txt
#
# -----------------------------------------------------------------------------
$user = "Nwtraders\administrator"
$password = ConvertTo-SecureString -String (Get-content C:\fso\passwordHash.txt)
$credential = new-object system.management.automation.pscredential $user,$password
Get-WmiObject -class Win32_Bios -Computername 157.217.58.110 -Credential $credential
