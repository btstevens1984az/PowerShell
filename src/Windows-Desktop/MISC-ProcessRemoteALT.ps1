# Purpose: MISC-ProcessRemoteALT — Windows desktop configuration and management.
#   James Wylde 2020

#----------------------------------------------------------------------------------------#
#   Modules

New-PSSession -ComputerName 168.23.139.1

$process = Get-Process mmc -ErrorAction SilentlyContinue
if ($process) {
  $process.CloseMainWindow()
  Sleep 5
  if (!$process.HasExited) {
    $process | Stop-Process -Force
  }
}
