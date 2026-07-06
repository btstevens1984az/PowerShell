# Purpose: Get-WindowsUpdatesGridView — Windows Update and patch management.
Function Get-WindowsUpdatesGridView {
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [String]$ComputerName
  ) 
Get-HotFix -ComputerName "$ComputerName" -ErrorAction SilentlyContinue | Select-Object PSComputername, HotfixID, InstalledOn | Out-GridView
}
