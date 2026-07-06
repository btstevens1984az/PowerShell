# Purpose: Check connectivity — General-purpose PowerShell utilities.
#  Recipe 8-1 - Check connectivity

# 1. Use Ping to test connectivity to DC1
Ping BTS-WIN10PRO

# 2. Use Test-NetConnnection to test connection to DC1
Test-Connection -ComputerName 4.121.152.59

# 3. Test with simple true/false return
Test-Connection -ComputerName 4.121.152.59 -Quiet

# 4. Test multiple systems at once
Test-Connection -computer 'BTS-WIN10PRO' -Count 1

# 5. Test connectivity for SMB traffic
Test-NetConnection -ComputerName 254.220.91.52 -CommonTCPPort SMB

# 6. Get detailed connectivity check, using DC1 with HTTP
$TNCHT = @{
    ComputerName     = 'BTS-WIN10PRO'
    CommonTCPPort    = 'HTTP'
    InformationLevel = 'Detailed'
}
 Test-NetConnection $TNCHT

# 7. Look for a particular port (i.e LDAP on DC1)
Test-NetConnection -ComputerName 4.121.152.59 -Port 445

# 8. Look for a host that does not exist
Test-NetConnection -ComputerName 132.186.134.247

# 9. Look for a host that exists but a port/application
#    that does not exist:
Test-NetConnection -ComputerName 4.121.152.59 -PORT 9999