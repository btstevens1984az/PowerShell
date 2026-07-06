# Purpose: ConnectionsWithProcessName — Windows desktop configuration and management.
<#
  This will get all connections with Get-NetTCPConnection cmdlet,
  filter them by list of names provided in $Name parameter,
  display it in custom table and save to excel sheet.
#>
param(
  [string[]]$NameToFilter = '*',
  [switch]$DoPing,
  [switch]$DoGetHost
)
#Requires -Version 7
#Requires -Modules ImportExcel


Set-Variable ProcessOfInterest -Option ReadOnly -Value $NameToFilter # Name(s) for the process(es) of interest
Set-Variable Output -Option ReadOnly -Value "./output.xlsx" # Name for output xlsx file
Set-Variable SheetName -Option ReadOnly -Value "process connections" # Name for the page in the exel file
# Helper function to get hostname with Ip
function GetHost {
  param ([string]$Ip, $DoGetHost)
  [string]$ResolvedDN = '-'
  if ( $DoGetHost ) {
    try {
      $ResolvedDN = [System.Net.Dns]::GetHostByAddress($Ip).Hostname
    } catch {
      $ResolvedDN = '~'
    }
  }
  return $ResolvedDN
}
$getHostDef = $function:GetHost.ToString() # Serializing function to pass into ForEach-Object -Parallel (5)
# Helper ping function
function PingHost {
  param ([string]$Ip, $DoPing)
  [int]$Latency = -1
  if ( $DoPing ) {
    try {
      $Latency = (Test-Connection -TargetName $Ip -Count 1).Latency
    } catch {
      $Latency = -2
    }
  }
  return $Latency
}
$pingHostDef = $function:PingHost.ToString() # Serializing function to pass into ForEach-Object -Parallel (5)

# Helper function to return name of shared service (instead of 'svchost')
function ProcessOrServiceName {
  param ([System.Object]$Process)

  [string]$Name = '-'
  # get Service name through CIM objects (6,7)
  if ($Process.Name -eq 'svchost'){
    $Name = (
      Get-CimInstance -ClassName Win32_Service | ` # Get CIM (Wim, since we on windows) object of services
      Where-Object {
        $_.Started -eq "True" -and ` # Only currently running services
        $_.ProcessId -eq $Process.Id # With process ID we are interested in
      }
    ).Name
  } else {
    $Name = $Process.Name
  }
  return $Name
}
$processOrServiceNameDef = $function:ProcessOrServiceName.ToString() # Serializing function to pass into ForEach-Object -Parallel (5)

# Get all TCP Connections whith our process names
$Connections = Get-NetTCPConnection `
  -AppliedSetting Internet ` # Filter conections optimised for internet (1)
  | Sort-Object -Property RemoteAddress ` # Sort by remote Addresses
  | Where-Object -Value "127.0.0.1" -NotIn -Property RemoteAddress ` # Filter locallhost connections
  | Where-Object -Property OwningProcess -In -Value (Get-Process -Name $ProcessOfInterest).Id ` # Filter by the Name for a process of interest
  | Select-Object -Property `
      OwningProcess, `
      LocalPort, `
      RemoteAddress, `
      RemotePort # Filter only fields that we need

# Enriching $Connections object (3)
$Connections | ForEach-Object -Parallel {
  $function:GetHost = $using:getHostDef # recreating function from string definition in every single context (5)
  $function:PingHost = $using:pingHostDef # recreating function from string definition in every single context (5)
  $function:ProcessOrServiceName = $using:processOrServiceNameDef # recreating function from string definition in every single context (5)
  $_ | Add-Member -NotePropertyName Ping -NotePropertyValue (PingHost -Ip $_.RemoteAddress -DoPing $($using:DoPing))
  $_ | Add-Member -NotePropertyName OwningProcessName -NotePropertyValue (ProcessOrServiceName (Get-Process -Id $_.OwningProcess))
  $_ | Add-Member -NotePropertyName Hostname -NotePropertyValue(GetHost -Ip $_.RemoteAddress -DoGetHost $($using:DoGetHost))
  $_ | Add-Member -NotePropertyName CommandLine -NotePropertyValue((Get-Process -Id $_.OwningProcess).CommandLine)
  }

# Outputing to STDIO with custom table formatting
$Connections | Format-Table `
  @{Label = "OwningProcessName";Expression = {[string]($_.OwningProcessName)}}, `
  @{Label = "LocalPort";Expression = {[int]($_.LocalPort)}}, `
  @{Label = "RemoteAddress";Expression = {[string]($_.RemoteAddress)}}, `
  @{Label = "Port";Alignment = "Left";Expression = {[int]($_.RemotePort)}}, `
  @{Label = "Ping";Expression = {[int]$_.Ping}}, `
  @{Label = "Hostname";Expression = {[string]($_.Hostname)}}

# Outputing to excel using ImportExcel module (4)
$Connections | Export-Excel $Output -WorksheetName $SheetName -TitleBold -AutoSize -FreezeTopRow -AutoFilter

# Footnote:
#   1. Applied settings https://docs.microsoft.com/en-us/powershell/module/nettcpip/set-nettcpsetting?view=windowsserver2022-ps
#   2. Custom output tables https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/format-table?view=powershell-7.2
#   3. Adding custom properties and methods to PS object https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/add-member?view=powershell-7.2
#   4. help export-excel
#   5. Powershell have problems with function pasing https://stackoverflow.com/questions/61273189/how-to-pass-a-custom-function-inside-a-foreach-object-parallel
#   6. How to get service name for svchost process (deprecated, but usefull parameters)
#       Post on technet: https://social.technet.microsoft.com/Forums/en-US/ee950af0-8708-4ad1-b1fc-83456d377c0a/powershell-to-find-which-service-runs-under-which-svchost-process?forum=win10itprohardware#f0e7984a-86e4-4e94-99db-7df87f4c4c04
#       Deprecated Get-WmiObject https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-wmiobject?view=powershell-5.1
#   7. Get-CimInstance https://devblogs.microsoft.com/powershell/introduction-to-cim-cmdlets/