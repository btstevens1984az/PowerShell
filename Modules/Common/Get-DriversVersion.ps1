# Purpose: Get-DriversVersion — Reusable PowerShell function libraries.
# Function Name: Get-HWVersion
# Retreives device name, driver date, and driver version
# -------------------------------------------
function Get-DriversVersion($ComputerName, $DriverName) {

     $pingresult = Get-WmiObject win32_pingstatus -f "address='$ComputerName'"
     if($pingresult.statuscode -ne 0) { return }

     gwmi -Query "SELECT * FROM Win32_PnPSignedDriver WHERE DeviceName LIKE '%$DriverName%'" -ComputerNameName $ComputerName | 
           Sort DeviceName | 
           Select @{Name="Server";Expression={$_.__Server}}, DeviceName, @{Name="DriverDate";Expression={[System.Management.ManagementDateTimeconverter]::ToDateTime($_.DriverDate).ToString("MM/dd/yyyy")}}, DriverVersion
}