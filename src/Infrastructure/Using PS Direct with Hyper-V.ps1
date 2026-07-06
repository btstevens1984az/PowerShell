# Purpose: Using PS Direct with Hyper-V — Core infrastructure automation scripts.
# Recipe 11-2 - Using PS Direct with Hyper-V

# 1. Create a credential object for ReskitAdministrator:
$RKAn = 'BTS-WIN10PRO\btste'
$PS   = 'qw12QW!@'
$RKP  = ConvertTo-SecureString -String $PS -AsPlainText -Force
$T = 'System.Management.Automation.PSCredential'
$RKCred = New-Object -TypeName $T -ArgumentList $RKAn,$RKP

# 2. Display the details of the psdirect VM:
Get-VM -Name BTS-WIN10PROVM

# 3. Invoke a command on the VM, specifying VM name:
$SBHT = @{
    VMName      = 'BTS-WIN10PROVM'
    Credential  = $RKCred
    ScriptBlock = {hostname}
}
Invoke-Command @SBHT

# 4. Invoke a command based on VMID:
$VMID = (Get-VM -VMName BTS-WIN10PROVM).VMId.Guid
Invoke-Command -VMid $VMID -Credential $RKCred  -ScriptBlock {hostname}

# 5. Enter a PS remoting session with the psdirect VM:
Enter-PSSession -VMName BTS-WIN10PROVM -Credential $RKCred
Get-CimInstance -Class Win32_ComputerSystem
Exit-PSSession