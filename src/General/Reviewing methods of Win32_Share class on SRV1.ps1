# Purpose: Reviewing methods of Win32 Share class on SRV1 — General-purpose PowerShell utilities.


# 1. Reviewing methods of Win32_Share class on SRV1
Get-CimClass -ClassName Win32_Share | 
  Select-Object -ExpandProperty CimClassMethods

# 2. Reviewing properties of Win32_Share class
Get-CimClass -ClassName Win32_Share | 
  Select-Object -ExpandProperty CimClassProperties |
    Format-Table -Property Name, CimType

# 3. Creating a new SMB share using the Create() statuc method
$NSHT = @{
  Name        = 'BTS-WIN10PROShare'
  Path        = 'C:\Temp'
  Description = 'BTS-WIN10PRO Share'
  Type        = [uint32] 0 # disk
}    
Invoke-CimMethod -ClassName Win32_Share -MethodName Create -Arguments $NSHT

# 4. Viewing the new SMB share
Get-SMBShare -Name 'BTS-WIN10PROShare'

# 5. Viewing the new SMB share using Get-CimInstance
Get-CimInstance -Class Win32_Share -Filter "Name = 'BTS-WIN10PROShare'"

# 6. Removing the share
Get-CimInstance -Class Win32_Share -Filter "Name = 'BTS-WIN10PROShare'" |
  Invoke-CimMethod -MethodName Delete