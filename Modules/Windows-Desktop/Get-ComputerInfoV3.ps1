# Purpose: Get-ComputerInfoV3 — Windows desktop configuration and management.
Function Get-ComputerInfoV3 {
<#
ComputerName          : 114.148.18.125
Manufacturer          : Dell Inc.
ProcessorArchitecture : 64
QueryStatus           : Success
Domain                : example.com
User                  : YOURDOMAIN\username
Laptop                : False
OperatingSystem       : Microsoft Windows 10 Enterprise 2016 LTSB
SerialNumber          : 7PDMDH2
MemoryGB              : 32
Model                 : OptiPlex 7040
OSArchitecture        : 64
IPAddress             : 28.241.205.32
ServicePack           : 0
PSComputerName        : localhost
PSSourceJobInstanceId : b5dd2245-9b88-422c-9980-55310e93b7ed
#>
workflow UpdateComputerInventory {
  $computers = Get-Content -Path C:\Temp\Test.txt
  ForEach -parallel ($computer in $computers) {
    Get-ComputerInfo -ComputerName $computer
  }
}
UpdateComputerInventory

function Get-ComputerInfo {
  [CmdletBinding()]
  param (
    [parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)][string[]]$ComputerName
  )
  BEGIN { }
  PROCESS {
    foreach ($Computer in $ComputerName) {
      $outputProperties = @{
        QueryStatus           = $null;
        ComputerName          = $Computer;
        User                  = $null;
        IPAddress             = $null;
        Manufacturer          = $null;
        Model                 = $null;
        ProcessorArchitecture = $null;
        OperatingSystem       = $null;
        OSArchitecture        = $null;
        ServicePack           = $null;
        SerialNumber          = $null;
        Domain                = $null;
        MemoryGB              = $null;
      }
      try {
        Write-Verbose "Attempting to connect to $Computer"
        Test-Connection -ComputerName $Computer -Count 1 -ErrorAction stop | Out-Null
        $CimSession = New-CimSession -SessionOption (New-CimSessionOption -Protocol DCOM) -ComputerName $Computer
        Write-Verbose "Getting IP Address for $computer"
        $ipaddress  = Get-CimInstance -CimSession $CimSession -Class Win32_NetworkAdapterConfiguration | ?{ $_.DefaultIPGateway -notlike '' } | Select-Object -ExpandProperty IPAddress | ?{ $_ -notlike '*:*' }
        Write-Verbose "Getting Hardware and BIOS information for $computer"
        $computerSystem = Get-CimInstance -CimSession $CimSession -Class Win32_ComputerSystem
        $processor  = Get-CimInstance -CimSession $CimSession -Class Win32_Processor
        $bios = Get-CimInstance -CimSession $CimSession -Class Win32_BIOS
        $memory     = Get-CimInstance -CimSession $CimSession -Class win32_physicalmemory | Measure-Object -Sum Capacity | Select -ExpandProperty Sum
        Write-Verbose "Getting OS information for $computer"
        $operatingSystem = Get-CimInstance -CimSession $CimSession -Class Win32_OperatingSystem
        Write-Verbose "Getting user information for $computer"
        $SIDFilter = "NOT SID = 'S-1-5-18' AND NOT SID = 'S-1-5-19' AND NOT SID = 'S-1-5-20'"
        $lastuser  = Get-CimInstance -CimSession $CimSession -Class Win32_UserProfile -Filter $SIDFilter | Sort-Object -Property LastUseTime -Descending | Select-Object -First 1
        $userprincipal = New-Object System.Security.Principal.SecurityIdentifier($lastUser.SID)
        $outputProperties['QueryStatus']           = "Success"
        $outputProperties['ComputerName']          = $computerSystem.Name
        $outputProperties['IPAddress']             = $ipaddress
        $outputProperties['User']                  =
          $userprincipal.Translate([System.Security.Principal.NTAccount]).Value
        $outputProperties['SerialNumber']          = $bios.SerialNumber
        $outputProperties['Laptop']                = $computerSystem.PCSystemType -eq 2
        $outputProperties['Manufacturer']          = $computerSystem.Manufacturer
        $outputProperties['Model']                 = $computerSystem.Model
        $outputProperties['ProcessorArchitecture'] = $processor.DataWidth
        $outputProperties['Domain']                = $computerSystem.Domain
        $outputProperties['OperatingSystem']       = $operatingSystem.Caption
        $outputProperties['OSArchitecture']        = $processor.AddressWidth
        $outputProperties['ServicePack']           = $operatingSystem.ServicePackMajorVersion
        $outputProperties['MemoryGB']              = $memory / 1gb
      } catch {
        Write-Warning "Failed to connect to $Computer"
        $outputProperties['QueryStatus'] = "Failed"
      } finally {
        New-Object PSObject -Property $outputProperties
      }
    }
  }   ### Process block
  END { }
}
}