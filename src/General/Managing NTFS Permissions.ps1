# Purpose: Managing NTFS Permissions — General-purpose PowerShell utilities.
# Recipe 10.1 - Managing NTFS Permissions
# 
# Run on SRV2 -After creating F: on Disk 1.

# 1. Downloading NTFSSecurity module from PSGallery
Install-Module NTFSSecurity -Force

# 2. Getting commands in the module
Get-Command -Module NTFSSecurity 

# 3. Creating a new folder and a file in the folder
New-Item -Path C:\Temp -ItemType Directory |
    Out-Null
"Secure" | Out-File -FilePath C:\Temp\Secure.Txt
Get-ChildItem -Path C:\Temp

# 4. Viewing ACL of the folder
Get-NTFSAccess -Path C:\Temp |
  Format-Table -AutoSize

# 5. Viewing ACL of the file
Get-NTFSAccess C:\Temp\Secure.Txt |
  Format-Table -AutoSize

# 6. Creating the BStevensGroup group in AD if it does not exist
$SB = {
  try {
    Get-ADGroup -Identity 'BStevensGroup' -ErrorAction Stop
  }
  catch {
    New-ADGroup -Name BStevensGroup -GroupScope Global |
      Out-Null
  }
}
Invoke-Command -ComputerName 4.121.152.59 -ScriptBlock $SB

# 7. Displaying BStevensGroup AD Group
Invoke-Command -ComputerName 4.121.152.59 -ScriptBlock {
                                   Get-ADGroup -Identity BStevensGroup}

# 8. Addding explicit full control for DomainAdmins
$AHT1 = @{
  Path         = 'C:\Temp'
  Account      = 'BTS-WIN10PRO\Domain Admins' 
  AccessRights = 'FullControl'
}
Add-NTFSAccess @AHT1

# 9. Removing builtin\users access from secure.txt file
$AHT2 = @{
  Path         = 'C:\Temp\Secure.Txt'
  Account      = 'Builtin\Users'
  AccessRights = 'FullControl'
}  
Remove-NTFSAccess @AHT2

# 10. Removing inherited rights for the folder:
$IRHT1 = @{
  Path                       = 'C:\Temp'
  RemoveInheritedAccessRules = $True
}
Disable-NTFSAccessInheritance @IRHT1

# 11. Adding BStevensGroup group access to the folder
$AHT3 = @{
  Path         = 'C:\Temp\'
  Account      = 'BTS-WIN10PRO\BStevensGroup' 
  AccessRights = 'FullControl'
}
Add-NTFSAccess @AHT3

# 12. Getting ACL on path
Get-NTFSAccess -Path C:\Temp |
  Format-Table -AutoSize

# 13. Getting resulting ACL on the file
Get-NTFSAccess -Path C:\Temp\Secure.Txt |
  Format-Table -AutoSize