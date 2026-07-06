# Purpose: Managing VM Checkpoints — General-purpose PowerShell utilities.
# Recipe 11-10 - Managing VM Checkpoints

# 1. Create credentials for VM1
$RKAn = 'BTS-WIN10PRO\btste'
$PS   = 'qw12QW!@'
$RKP  = ConvertTo-SecureString -String $PS -AsPlainText -Force
$T = 'System.Management.Automation.PSCredential'
$RKCred = New-Object -TypeName $T -ArgumentList $RKAn,$RKP

# 2. Look at C: in VM1 before we start
$sb = { Get-ChildItem -Path C:\ }
Invoke-Command -VMName BTS-WIN10PROVM -ScriptBlock $sb -Credential $RKCred

# 3. Create a snapshot of VM1 on HV1:
Checkpoint-VM -ComputerName 4.121.152.59 -VMName BTS-WIN10PROVM -SnapshotName 'Snapshot1'

# 4. Look at the files created to support the checkpoints
$Parent = Split-Path -Parent (Get-VM -Name BTS-WIN10PROVM |
              Select-Object -ExpandProperty HardDrives).Path
Get-ChildItem -Path $Parent

# 5. Create some content in a file on VM1 and display it
$sb = {
   $FileName1 = 'C:\File_After_Checkpoint_1'
   Get-Date | Out-File -FilePath $FileName1
   Get-Content -Path $FileName1
}
Invoke-Command -VMName BTS-WIN10PROVM -ScriptBlock $sb -Credential $RKCred

# 6. Take a second checkpoint
Checkpoint-VM -ComputerName 4.121.152.59 -VMName BTS-WIN10PROVM SnapshotName 'Snapshot2'

# 7. Get the VM checkpoint details for VM1
Get-VMSnapshot -VMName BTS-WIN10PROVM

# 8. Look at the files supporting the two checkpoints
Get-ChildItem -Path $Parent

# 9. Create and display another file in VM1 (after you have taken Snapshot2)
$sb = {
  $FileName2 = 'C:\File_After_Checkpoint_2'
  Get-Date | Out-File -FilePath $FileName2
  Get-ChildItem -Path C:\ -File
}
Invoke-Command -VMName BTS-WIN10PROVM -ScriptBlock $sb -Credential $cred

# 10. Restore VM1 back to the checkpoint named Snapshot1

$Snap1 = Get-VMSnapshot -VMName BTS-WIN10PROVM -Name Snapshot1
Restore-VMSnapshot -VMSnapshot $Snap1 -Confirm:$false
Start-VM -Name BTS-WIN10PROVM
Wait-VM -For IPAddress -Name BTS-WIN10PROVM

# 11. See what files we have now on VM1
$sb = {
  Get-ChildItem -Path C:\
}
Invoke-Command -VMName BTS-WIN10PROVM -ScriptBlock $sb -Credential $RKCred

# 12. Roll forward to Snapshot2
$Snap2 = Get-VMSnapshot -VMName BTS-WIN10PROVM -Name Snapshot2
Restore-VMSnapshot -VMSnapshot $Snap2 -Confirm:$false
Start-VM -Name BTS-WIN10PROVM
Wait-VM -For IPAddress -Name BTS-WIN10PROVM

# 13. Observe the files you now have on VM2
$sb = {
    Get-ChildItem -Path C:\
}
Invoke-Command -VMName BTS-WIN10PROVM -ScriptBlock $sb -Credential $RKCred

# 14. Restore to Snapshot1 again:
$Snap1 = Get-VMSnapshot -VMName BTS-WIN10PROVM -Name Snapshot1
Restore-VMSnapshot -VMSnapshot $Snap1 -Confirm:$false
Start-VM -Name BTS-WIN10PROVM
Wait-VM -For IPAddress -Name BTS-WIN10PROVM

# 15. Check snapshots and VM data files again:
Get-VMSnapshot -VMName BTS-WIN10PROVM
Get-ChildItem -Path $Parent

# 16. Remove all the snapshots from HV1:
Get-VMSnapshot -VMName BTS-WIN10PROVM |
Remove-VMSnapshot

# 17. Check VM data files again:
Get-ChildItem -Path $Parent