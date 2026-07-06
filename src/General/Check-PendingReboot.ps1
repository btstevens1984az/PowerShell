# Purpose: Check-PendingReboot — General-purpose PowerShell utilities.
# Filename:      Check-PendingReboot.ps1
# Description:   Imports a list of computers from a CSV file and then checks each of the
#                computers for the RebootPending registry key. If the key is present, 
#                the script restarts the computer upon confirmation from the user.
# Error accessing registry will appear as RED message in console.

$filePath = "C:\tmp\servers.txt"
$Computers = (get-content -Path $filePath )

ForEach ($Machine in $Computers)
{
   $baseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $Machine)
   $key = $baseKey.OpenSubKey("Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\")
   $subkeys = $key.GetSubKeyNames()
   $key.Close()
   $baseKey.Close()
write-host $Machine is processing now
   If ($subkeys | Where {$_ -eq "RebootPending"}) 
   {
      Write-Host -foregroundcolor yellow "There is a pending reboot for" $Machine
	  # the next line can be enabled by removing the VOID items and comments.  A prompt to confirm reboot then will show in the console
      ## Restart-Computer 10.199.208.191 $MachineVoidVOID -confirm
   }
   Else 
   {
      # Write-Host "No reboot is pending for" $Machine
   }
}
