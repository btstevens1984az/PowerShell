Function Get-SysInfo {
<#
.SYNOPSIS
  The purpose of this script is to retrieve information of remote systems.
  
.DESCRIPTION
  This is a simple script with UI to retrieve information of remote system regarding the hardware,
  software and peripherals.

  It will gather hardware specifications, peripherals, installed software, running processes, services
  and Operating System through a very simple and functioning GUI. You can also perform Ping Test, NetStat,
  Remote Desktop and export the results in a text file or email the results.

.RELATED LINKS
  https://www.sconstantinou.com

  Version:      1.3

                                  - Added date and time for the results
                                  - Updated description

                                  - Added TCP Connection information
                                  - Added Title for each information retrieval

                                  - Added Battery Information
                                  - Added Portable Battery Information
                                  - Added Network Settings Information
                                  - Added ping connection test of remote system
                                  - Added Remote Desktop connection to the machine.
                                  - Warning for the use of Win32_Product class
                                  - Added option for Win32Reg_AddRemovePrograms class
                                  - Added visibility to Taskbar
                                  - Added Help information

    
  Release Date: 22-02-2018
   

.EXAMPLE
  Run the Get-SysInfo script to retrieve the information.
  Get-SysInfo.ps1
#>
$System_info = {
   $ComputerName = $txt_ComputerName.Text
   $System = Get-CimInstance -Class Win32_ComputerSystem -ComputerName $ComputerName
   $lbl_sysinfo.Text = "System Information - $(Get-Date)"
   $lbl_sysinfo.Text += $System | FL -Property Name,
                                               Manufacturer,
                                               Model,
                                               PartOfDomain,
                                               Domain,
                                               Workgroup,
                                               DNSHostName,
                                               NumberOfProcessors,
                                               NumberOfLogicalProcessors,
                                               TotalPhysicalMemory,
                                               CurrentTimeZone,
                                               DaylightInEffect,
                                               HypervisorPresent,
                                               PrimaryOwnerName,
                                               UserName | Out-String}

$bios_info = {
   $ComputerName = $txt_ComputerName.Text
   $Bios = Get-CimInstance -Class Win32_BIOS -ComputerName $ComputerName
   $lbl_sysinfo.Text = "BIOS Information - $(Get-Date)"
   $lbl_sysinfo.Text += $Bios | FL -Property Name,
                                             SerialNumber,
                                             Version,
                                             BIOSVersion,
                                             ReleaseData | Out-String}

$CPU_info = {
   $ComputerName = $txt_ComputerName.Text
   $CPU = Get-CimInstance -Class Win32_Processor -ComputerName $ComputerName 
   $lbl_sysinfo.Text = "CPU Information - $(Get-Date)"
   $lbl_sysinfo.Text += $CPU | FL -Property DeviceID,
                                            Manufacturer,
                                            Name,
                                            Caption,
                                            L2CacheSize,
                                            L3CacheSize,
                                            LoadPercentage,
                                            CurrentClockSpeed | Out-String}

$RAM_info = {
   $ComputerName = $txt_ComputerName.Text
   $RAM = Get-CimInstance -Class Win32_PhysicalMemory -ComputerName $ComputerName
   $lbl_sysinfo.Text = "RAM Information - $(Get-Date)"
   $lbl_sysinfo.Text += $RAM | FL -Property Tag,
                                            DeviceLocator,
                                            Manufacturer,
                                            PartNumber,
                                            SerialNumber,
                                            Capacity,
                                            Speed | Out-String}

$MB_info = {
   $ComputerName = $txt_ComputerName.Text
   $MB = Get-CimInstance -Class Win32_BaseBoard -ComputerName $ComputerName
   $lbl_sysinfo.Text = "MotherBoard Information - $(Get-Date)"
   $lbl_sysinfo.Text += $MB | FL -Property Manufacturer,
                                           Model,
                                           Version | Out-String}

$PhysicalDrives_info = {
   $ComputerName = $txt_ComputerName.Text
   $PhysicalDrives = Get-CimInstance -Class Win32_DiskDrive -ComputerName $ComputerName
   $lbl_sysinfo.Text = "Physical Drives Information - $(Get-Date)"
   $lbl_sysinfo.Text += $PhysicalDrives | FL -Property DeviceID,
                                                       FirmwareRevision,
                                                       Manufacturer,
                                                       Model,
                                                       MediaType,
                                                       SerialNumber,
                                                       InterfaceType,
                                                       Partitions,
                                                       Size,
                                                       TotalCylinders,
                                                       TotalHeads,
                                                       TotalSectors,
                                                       TotalTracks,
                                                       TracksPerCylinderBytePerSector,
                                                       SectorsPerTrack,
                                                       Capabilities,
                                                       CapabilityDescriptions,
                                                       Status | Out-String}

$LogicalDrives_info = {
   $ComputerName = $txt_ComputerName.Text
   $LogicalDrives = Get-CimInstance -Class Win32_LogicalDisk -ComputerName $ComputerName
   $lbl_sysinfo.Text = "Logical Drives Information - $(Get-Date)"
   $lbl_sysinfo.Text += $LogicalDrives | FL -Property DeviceID,
                                                      Description,
                                                      VolumeName,
                                                      ProviderName,
                                                      Size,
                                                      FreeSpace,
                                                      VolumeSerialNumber,
                                                      FileSystem,
                                                      Compressed | Out-String}

$GPU_info = {
   $ComputerName = $txt_ComputerName.Text
   $GPU = Get-CimInstance -Class Win32_VideoController -ComputerName $ComputerName
   $lbl_sysinfo.Text = "GPU Information - $(Get-Date)"
   $lbl_sysinfo.Text += $GPU | FL -Property DeviceID,
                                            Name,
                                            VideoProcessor,
                                            AdapterDACType,
                                            AdapterRAM,
                                            DriverDate,
                                            DriverVersion,
                                            VideoModeDescription,
                                            CurrentBitsPerPixel,
                                            CurrentHorizontalResolution,
                                            CurrentVerticalResolution,
                                            CurrentNumberOfColors,
                                            CurrentRefreshRate,
                                            MaxRefreshRate,
                                            MinRefreshRate,
                                            Status | Out-String}

$Network_info = {
   $ComputerName = $txt_ComputerName.Text
   $Network = Get-CimInstance -Class Win32_NetworkAdapter -ComputerName $ComputerName
   $lbl_sysinfo.Text = "Network Devices Information - $(Get-Date)"
   $lbl_sysinfo.Text += $Network | FL -Property DeviceID,
                                                Name,
                                                Manufacturer,
                                                ProductName,
                                                ServiceName,
                                                MACAddress,
                                                AdapterType,
                                                NetConnectionID,
                                                NetEnabled,
                                                Speed,
                                                PhysicalAdapter,
                                                TimeOfLastReset | Out-String}

$NetSettings_info = {
   $ComputerName = $txt_ComputerName.Text
   $NetSettings = Get-CimInstance -Class Win32_NetworkAdapterConfiguration -ComputerName $ComputerName
   $lbl_sysinfo.Text = "Network Configuration Information - $(Get-Date)"
   $lbl_sysinfo.Text += $NetSettings | FL -Property Description,
                                                    DHCPEnabled, 
                                                    DHCPLeaseObtained,
                                                    DNSDomain,
                                                    DNSDomainSuffixSearchOrder,
                                                    DHCPServer,
                                                    DNSHostName,
                                                    DNSServerSearchOrder,
                                                    DomainDNSRegistrationEnabled,
                                                    FullDNSRegistrationEnabled,
                                                    IPEnabled,
                                                    IPAddress,
                                                    DefaultIPGateway,
                                                    IPSubnet,
                                                    MACAddress,
                                                    ServiceName | Out-String}

$Monitor_info = {
   $ComputerName = $txt_ComputerName.Text
   $Monitor = Get-CimInstance -Class Win32_DesktopMonitor -ComputerName $ComputerName
   $lbl_sysinfo.Text = "Monitors Information - $(Get-Date)"
   $lbl_sysinfo.Text += $Monitor | FL -Property DeviceID,
                                                Name,
                                                MonitorManufacturer,
                                                MonitorType,
                                                PixelsPerXLogicalInch,
                                                PixelPerYLogicalInch,
                                                ScreenHeight,
                                                ScreenWidth,
                                                Status | Out-String}

$OS_info = {
   $ComputerName = $txt_ComputerName.Text
   $OS = Get-CimInstance -Class Win32_OperatingSystem -ComputerName $ComputerName
   $lbl_sysinfo.Text = "Operating System Information - $(Get-Date)"
   $lbl_sysinfo.Text += $OS | FL -Property Name,
                                           Manufacturer,
                                           Caption,
                                           Version,
                                           MUILanguages,
                                           BuildNumber,
                                           BuildType,
                                           InstallDate,
                                           OSArchitecture,
                                           PortableOperatingSystem,
                                           Primary,
                                           BootDevice,
                                           LastBootUpTime,
                                           LocalDateTime,
                                           CurrentTimeZone,
                                           RegisteredUser,
                                           SerialNumber,
                                           SystemDevice,
                                           SystemDirectory,
                                           SystemDrive,
                                           WindowsDirectory,
                                           EncryptionLevel,
                                           FreePhysicalMemory,
                                           FreeSpaceInPagingFiles,
                                           FreeVirtualMemory,
                                           SizeStoredInPagingFiles,
                                           TotalVirtualMemorySize,
                                           TotalVisibleMemorySize,
                                           Status | Out-String}

$Keyboard_info = {
   $ComputerName = $txt_ComputerName.Text
   $Keyboard = Get-CimInstance -Class Win32_Keyboard -ComputerName $ComputerName
   $lbl_sysinfo.Text = "Keyboard Information - $(Get-Date)"
   $lbl_sysinfo.Text += $Keyboard | FL -Property Description,
                                                 Caption,
                                                 NumberOfFunctionKeys | Out-String}

$Mouse_info = {
   $ComputerName = $txt_ComputerName.Text
   $Mouse = Get-CimInstance -Class Win32_PointingDevice -ComputerName $ComputerName
   $lbl_sysinfo.Text = "Pointing Device Information - $(Get-Date)"
   $lbl_sysinfo.Text += $Mouse | FL -Property Description,
                                              Name,
                                              HardwareType,
                                              Manufacturer | Out-String}

$CDROM_info = {
   $ComputerName = $txt_ComputerName.Text
   $CDROM = Get-CimInstance -Class Win32_CDROMDrive -ComputerName $ComputerName
   $lbl_sysinfo.Text = "CD-ROM Drives Information - $(Get-Date)"
   $lbl_sysinfo.Text += $CDROM | FL -Property Drive,
                                              Name,
                                              Caption,
                                              Description,
                                              Manufacturer,
                                              MediaType,
                                              MfrAssignedRevisionLevel,
                                              CapabilityDescriptions,
                                              MediaLoaded | Out-String}

$Sound_info = {
   $ComputerName = $txt_ComputerName.Text
   $Sound = Get-CimInstance -Class Win32_SoundDevice -ComputerName $ComputerName
   $lbl_sysinfo.Text = "Sound Devices Information - $(Get-Date)"
   $lbl_sysinfo.Text += $Sound | FL -Property DeviceID,
                                              Name,
                                              Manufacturer,
                                              ProductName | Out-String}

$Printers_info = {
   $ComputerName = $txt_ComputerName.Text
   $Printers = Get-CimInstance -Class Win32_Printer -ComputerName $ComputerName
   $lbl_sysinfo.Text = "Printers Information - $(Get-Date)"
   $lbl_sysinfo.Text += $Printers | FL -Property DeviceID,
                                                 Name,
                                                 HorizontalResolution,
                                                 VerticalResolution,
                                                 Default,
                                                 DriverName,
                                                 Direct,
                                                 Network,
                                                 Local,
                                                 Hidden,
                                                 KeepPrintedJobs,
                                                 PrintJobDataType,
                                                 PrintProcessor,
                                                 PortName,
                                                 Shared,
                                                 ServerName,
                                                 SpoolEnabled,
                                                 WorkOffline,
                                                 CapabilityDescriptions,
                                                 Status | Out-String}

$Fan_info = {
   $ComputerName = $txt_ComputerName.Text
   $Fan = Get-CimInstance -Class Win32_Fan -ComputerName $ComputerName
   $lbl_sysinfo.Text = "Fans Information - $(Get-Date)"
   $lbl_sysinfo.Text += $Fan | FL -Property Name,
                                            Caption,
                                            Description,
                                            InstallDate,
                                            ActiveCooling,
                                            DesiredSpeed,
                                            VariableSpeed | Out-String}

$Battery_info = {
   $ComputerName = $txt_ComputerName.Text
   $Battery = Get-CimInstance -Class Win32_Battery -ComputerName $ComputerName
   $lbl_sysinfo.Text = "Battery Information - $(Get-Date)"
   $lbl_sysinfo.Text += $Battery | FL -Property * | Out-String}

$PortBattery_info = {
   $ComputerName = $txt_ComputerName.Text
   $PortBattery = Get-CimInstance -Class Win32_PortableBattery -ComputerName $ComputerName
   $lbl_sysinfo.Text = "Portable Battery Information - $(Get-Date)"
   $lbl_sysinfo.Text = $PortBattery | FL -Property * | Out-String}

$Software_info = {
   $ComputerName = $txt_ComputerName.Text

   $Product = { 
      $Warning = [System.Windows.MessageBox]::Show('Are you sure that you want to run this using Win32_Product class?','Warning','YesNo','Error')

      switch ($Warning){
         Yes {$SoftwareOption.Close()
              $Software = Get-CimInstance -Class Win32Reg_Product -ComputerName $ComputerName
              $lbl_sysinfo.Text = "Software Information - $(Get-Date)"
              $lbl_sysinfo.Text += $Software | FL -Property Name,
                                                            Version,
                                                            Description,
                                                            Vendor,
                                                            InstallDate,
                                                            InstallLocation,
                                                            HelpLink,
                                                            URLInfoAbout,
                                                            URLUpdateInfo | Out-String}
         No {Break}
      }
   }

   $AddRemove = {
      $SoftwareOption.Close()
      $Software = Get-CimInstance -Class Win32Reg_AddRemovePrograms -ComputerName $ComputerName
      $lbl_sysinfo.Text = "Software Information - $(Get-Date)"
      $lbl_sysinfo.Text += $Software | FL -Property DisplayName,
                                                    InstallDate,
                                                    Publisher,
                                                    Version | Out-String}

   $SoftwareOption = New-Object system.Windows.Forms.Form
   $SoftwareOption.Text = "Class Option"
   $SoftwareOption.Size = New-Object System.Drawing.Size(500,130)
   $SoftwareOption.AutoSize = $False
   $SoftwareOption.AutoScroll = $False
   $SoftwareOption.MinimizeBox = $False
   $SoftwareOption.MaximizeBox = $False
   $SoftwareOption.WindowState = "Normal"
   $SoftwareOption.SizeGripStyle = "Hide"
   $SoftwareOption.ShowInTaskbar = $True
   $SoftwareOption.Opacity = 1
   $SoftwareOption.FormBorderStyle = "Fixed3D"
   $SoftwareOption.StartPosition = "CenterScreen"

   $lbl_SoftwareOption = New-Object System.Windows.Forms.Label
   $lbl_SoftwareOption.Location = New-Object System.Drawing.Point(20,10)
   $lbl_SoftwareOption.Size = New-Object System.Drawing.Size(500,25)
   $lbl_SoftwareOption.Text = "Please select the class that you want to use:"
   $lbl_SoftwareOption.Font = $Font
   $SoftwareOption.Controls.Add($lbl_SoftwareOption)

   $btn_Product = New-Object System.Windows.Forms.Button
   $btn_Product.Location = New-Object System.Drawing.Point(10,50)
   $btn_Product.Size = New-Object System.Drawing.Size(230,25)
   $btn_Product.Text = "Win32_Product"
   $btn_Product.Font = $Font
   $btn_Product.Add_Click($Product)
   $SoftwareOption.Controls.Add($btn_Product)

   $btn_AddRemove = New-Object System.Windows.Forms.Button
   $btn_AddRemove.Location = New-Object System.Drawing.Point(250,50)
   $btn_AddRemove.Size = New-Object System.Drawing.Size(230,25)
   $btn_AddRemove.Text = "Win32_AddRemovePrograms"
   $btn_AddRemove.Font = $Font
   $btn_AddRemove.Add_Click($AddRemove)
   $SoftwareOption.Controls.Add($btn_AddRemove)

   $SoftwareOption.ShowDialog()
}


$Process_info = {
   $ComputerName = $txt_ComputerName.Text
   $Process = Get-CimInstance -Class Win32_Process -ComputerName $ComputerName
   $lbl_sysinfo.Text = "Processes Information - $(Get-Date)"
   $lbl_sysinfo.Text += $Process | FL -Property ProcessName,
                                                Path,
                                                CreationDate | Out-String}

$Services_info = {
   $ComputerName = $txt_ComputerName.Text
   $Services = Get-CimInstance -Class Win32_Service -ComputerName $ComputerName
   $lbl_sysinfo.Text = "Services Information - $(Get-Date)"
   $lbl_sysinfo.Text += $Services | FL -Property Name,
                                                 DisplayName,
                                                 Description,
                                                 StartMode,
                                                 Started,
                                                 State,
                                                 PathName | Out-String}

$Ping_Test_info = {
   $ComputerName = $txt_ComputerName.Text

   If ($ComputerName -eq ""){
      $lbl_sysinfo.ForeColor = "Red"
      $lbl_sysinfo.Text = "Please provide a computer name to test the connection"}
   else {
      $Ping_Test = Test-Connection $ComputerName
      $lbl_sysinfo.Text = "Ping Test Information - $(Get-Date)"
      $lbl_sysinfo.Text += $Ping_Test | Out-String}}

$RDP_Connection = {
   $ComputerName = $txt_ComputerName.Text
   mstsc /v:$ComputerName}

$Export = {
   $ComputerName = $txt_ComputerName.Text

   $TextFile = {
      $ExportOption.Close()

      if ($ComputerName -eq ""){
         $ComputerName = (Get-CimInstance -Class Win32_ComputerSystem).Name}

         $lbl_sysinfo.Text | Out-File C:\Temp\$ComputerName.txt}

   $Email = {
      if ($ComputerName -eq ""){
         $ComputerName = (Get-CimInstance -Class Win32_ComputerSystem).Name}

         $lbl_sysinfo.Text | Out-File C:\Temp\$ComputerName.txt

      $To  = @(($txt_Recipients.Text) -split ',')
      $Attachement = "C:\Temp\$ComputerName.txt"
      $Recipients.Close()

      $EmailCredentials = Get-Credential

      $From = $EmailCredentials.UserName

      $EmailParameters = @{
         To = $To
         Subject = "System Information - $ComputerName"
         Body = "Please find attached the information that you have requested."
         Attachments = $Attachement
         UseSsl = $True
         Port = "587"
         SmtpServer = "smtp.office365.com"
         Credential = $EmailCredentials
         From = $From}

      send-mailmessage @EmailParameters}

   $RecipientsDetails = {
      $ExportOption.Close()

      $Recipients = New-Object system.Windows.Forms.Form
      $Recipients.Text = "Recipients"
      $Recipients.Size = New-Object System.Drawing.Size(500,500)
      $Recipients.AutoSize = $False
      $Recipients.AutoScroll = $False
      $Recipients.MinimizeBox = $False
      $Recipients.MaximizeBox = $False
      $Recipients.WindowState = "Normal"
      $Recipients.SizeGripStyle = "Hide"
      $Recipients.ShowInTaskbar = $True
      $Recipients.Opacity = 1
      $Recipients.FormBorderStyle = "Fixed3D"
      $Recipients.StartPosition = "CenterScreen"

      $RecipientsInfo = @"
Please enter the recipient.

If there are multiple recipients, separate recipients with comma (,).
"@

      $lbl_Recipients = New-Object System.Windows.Forms.Label
      $lbl_Recipients.Location = New-Object System.Drawing.Point(0,10)
      $lbl_Recipients.Size = New-Object System.Drawing.Size(500,100)
      $lbl_Recipients.Text = $RecipientsInfo
      $lbl_Recipients.Font = $Font
      $Recipients.Controls.Add($lbl_Recipients)

      $txt_Recipients = New-Object System.Windows.Forms.TextBox
      $txt_Recipients.Location = New-Object System.Drawing.Point(10,120)
      $txt_Recipients.Size = New-Object System.Drawing.Size(460,100)
      $txt_Recipients.Font = $Font
      $Recipients.Controls.Add($txt_Recipients)

      $btn_Recipients = New-Object System.Windows.Forms.Button
      $btn_Recipients.Location = New-Object System.Drawing.Point(180,150)
      $btn_Recipients.Size = New-Object System.Drawing.Size(125,25)
      $btn_Recipients.Text = "OK"
      $btn_Recipients.Font = $Font
      $btn_Recipients.Add_Click($Email)
      $Recipients.Controls.Add($btn_Recipients)
      
      $Recipients.ShowDialog()}
    
   $ExportOption = New-Object system.Windows.Forms.Form
   $ExportOption.Text = "Export Method"
   $ExportOption.Size = New-Object System.Drawing.Size(500,130)
   $ExportOption.AutoSize = $False
   $ExportOption.AutoScroll = $False
   $ExportOption.MinimizeBox = $False
   $ExportOption.MaximizeBox = $False
   $ExportOption.WindowState = "Normal"
   $ExportOption.SizeGripStyle = "Hide"
   $ExportOption.ShowInTaskbar = $True
   $ExportOption.Opacity = 1
   $ExportOption.FormBorderStyle = "Fixed3D"
   $ExportOption.StartPosition = "CenterScreen"

   $lbl_ExportOption = New-Object System.Windows.Forms.Label
   $lbl_ExportOption.Location = New-Object System.Drawing.Point(20,10)
   $lbl_ExportOption.Size = New-Object System.Drawing.Size(500,25)
   $lbl_ExportOption.Text = "Please select how you want to export the results:"
   $lbl_ExportOption.Font = $Font
   $ExportOption.Controls.Add($lbl_ExportOption)

   $btn_TextFile = New-Object System.Windows.Forms.Button
   $btn_TextFile.Location = New-Object System.Drawing.Point(10,50)
   $btn_TextFile.Size = New-Object System.Drawing.Size(230,25)
   $btn_TextFile.Text = "Text File"
   $btn_TextFile.Font = $Font
   $btn_TextFile.Add_Click($TextFile)
   $ExportOption.Controls.Add($btn_TextFile)

   $btn_Email = New-Object System.Windows.Forms.Button
   $btn_Email.Location = New-Object System.Drawing.Point(250,50)
   $btn_Email.Size = New-Object System.Drawing.Size(230,25)
   $btn_Email.Text = "Email"
   $btn_Email.Font = $Font
   $btn_Email.Add_Click($RecipientsDetails)
   $ExportOption.Controls.Add($btn_Email)

   $ExportOption.ShowDialog()}

$NetStat = {
   $ComputerName = $txt_ComputerName.Text

   if ($ComputerName -eq ""){
      $LocalNetStat = Get-NetTCPConnection
      $lbl_sysinfo.Text = "NetStat Information - $(Get-Date)"
      $lbl_sysinfo.Text += $LocalNetStat | FT | Out-String}
   else{
      $RemoteNetStat = Invoke-Command -ComputerName $ComputerName -ScriptBlock {Get-NetTCPConnection}
      $lbl_sysinfo.Text = "NetStat Information - $(Get-Date)"
      $lbl_sysinfo.Text += $RemoteNetStat | FT | Out-String }}

Add-Type -AssemblyName System.Windows.Forms

$Font = New-Object System.Drawing.Font("Consolas",12,[System.Drawing.FontStyle]::Regular)

$MainForm = New-Object system.Windows.Forms.Form
$MainForm.Text = "Computer Information"
$MainForm.Size = New-Object System.Drawing.Size(1200,800)
$MainForm.AutoScroll = $True
$MainForm.MinimizeBox = $True
$MainForm.MaximizeBox = $True
$MainForm.WindowState = "Normal"
$MainForm.SizeGripStyle = "Hide"
$MainForm.ShowInTaskbar = $True
$MainForm.Opacity = 1
$MainForm.StartPosition = "CenterScreen"
$MainForm.ShowInTaskbar = $True
$MainForm.Font = $Font

$lbl_ComputerName = New-Object System.Windows.Forms.Label
$lbl_ComputerName.Location = New-Object System.Drawing.Point(0,5)
$lbl_ComputerName.Size = New-Object System.Drawing.Size(150,20)
$lbl_ComputerName.Font = $Font
$lbl_ComputerName.Text = "Computer Name"
$MainForm.Controls.Add($lbl_ComputerName)

$lbl_sysinfo = New-Object System.Windows.Forms.Label
$lbl_sysinfo.Location = New-Object System.Drawing.Point(155,50)
$lbl_sysinfo.Size = New-Object System.Drawing.Size(500,500)
$lbl_sysinfo.AutoSize = $True
$lbl_sysinfo.Font = $Font
$lbl_sysinfo.Text = ""
$MainForm.Controls.Add($lbl_sysinfo)

$txt_ComputerName = New-Object System.Windows.Forms.TextBox
$txt_ComputerName.Location = New-Object System.Drawing.Point(150,5)
$txt_ComputerName.Size = New-Object System.Drawing.Size(200,20)
$txt_ComputerName.Font = $Font
$MainForm.Controls.Add($txt_ComputerName)

$btn_System = New-Object System.Windows.Forms.Button
$btn_System.Location = New-Object System.Drawing.Point(5,50)
$btn_System.Size = New-Object System.Drawing.Size(145,25)
$btn_System.Font = $Font
$btn_System.Text = "System"
$btn_System.Add_Click($System_info)
$MainForm.Controls.Add($btn_System)

$btn_BIOS = New-Object System.Windows.Forms.Button
$btn_BIOS.Location = New-Object System.Drawing.Point(5,75)
$btn_BIOS.Size = New-Object System.Drawing.Size(145,25)
$btn_BIOS.Font = $Font
$btn_BIOS.Text = "BIOS"
$btn_BIOS.Add_Click($bios_info)
$MainForm.Controls.Add($btn_BIOS)

$btn_CPU = New-Object System.Windows.Forms.Button
$btn_CPU.Location = New-Object System.Drawing.Point(5,100)
$btn_CPU.Size = New-Object System.Drawing.Size(145,25)
$btn_CPU.Font = $Font
$btn_CPU.Text = "CPU"
$btn_CPU.Add_Click($cpu_info)
$MainForm.Controls.Add($btn_CPU)

$btn_RAM = New-Object System.Windows.Forms.Button
$btn_RAM.Location = New-Object System.Drawing.Point(5,125)
$btn_RAM.Size = New-Object System.Drawing.Size(145,25)
$btn_RAM.Font = $Font
$btn_RAM.Text = "RAM"
$btn_RAM.Add_Click($ram_info)
$MainForm.Controls.Add($btn_RAM)

$btn_MB = New-Object System.Windows.Forms.Button
$btn_MB.Location = New-Object System.Drawing.Point(5,150)
$btn_MB.Size = New-Object System.Drawing.Size(145,25)
$btn_MB.Font = $Font
$btn_MB.Text = "Motherboard"
$btn_MB.Add_Click($mb_info)
$MainForm.Controls.Add($btn_MB)

$btn_PhysicalDrives = New-Object System.Windows.Forms.Button
$btn_PhysicalDrives.Location = New-Object System.Drawing.Point(5,175)
$btn_PhysicalDrives.Size = New-Object System.Drawing.Size(145,25)
$btn_PhysicalDrives.Font = $Font
$btn_PhysicalDrives.Text = "Physical Drives"
$btn_PhysicalDrives.Add_Click($PhysicalDrives_info)
$MainForm.Controls.Add($btn_PhysicalDrives)

$btn_LogicalDrives = New-Object System.Windows.Forms.Button
$btn_LogicalDrives.Location = New-Object System.Drawing.Point(5,200)
$btn_LogicalDrives.Size = New-Object System.Drawing.Size(145,25)
$btn_LogicalDrives.Font = $Font
$btn_LogicalDrives.Text = "Logical Drives"
$btn_LogicalDrives.Add_Click($LogicalDrives_info)
$MainForm.Controls.Add($btn_LogicalDrives)

$btn_Graphics = New-Object System.Windows.Forms.Button
$btn_Graphics.Location = New-Object System.Drawing.Point(5,225)
$btn_Graphics.Size = New-Object System.Drawing.Size(145,25)
$btn_Graphics.Font = $Font
$btn_Graphics.Text = "Graphics"
$btn_Graphics.Add_Click($GPU_info)
$MainForm.Controls.Add($btn_Graphics)

$btn_Network = New-Object System.Windows.Forms.Button
$btn_Network.Location = New-Object System.Drawing.Point(5,250)
$btn_Network.Size = New-Object System.Drawing.Size(145,25)
$btn_Network.Font = $Font
$btn_Network.Text = "Network"
$btn_Network.Add_Click($Network_info)
$MainForm.Controls.Add($btn_Network)

$btn_NetSettings = New-Object System.Windows.Forms.Button
$btn_NetSettings.Location = New-Object System.Drawing.Point(5,275)
$btn_NetSettings.Size = New-Object System.Drawing.Size(145,25)
$btn_NetSettings.Font = $Font
$btn_NetSettings.Text = "Net Settings"
$btn_NetSettings.Add_Click($NetSettings_info)
$MainForm.Controls.Add($btn_NetSettings)

$btn_Monitors = New-Object System.Windows.Forms.Button
$btn_Monitors.Location = New-Object System.Drawing.Point(5,300)
$btn_Monitors.Size = New-Object System.Drawing.Size(145,25)
$btn_Monitors.Font = $Font
$btn_Monitors.Text = "Monitors"
$btn_Monitors.Add_Click($Monitor_info)
$MainForm.Controls.Add($btn_Monitors)

$btn_OS = New-Object System.Windows.Forms.Button
$btn_OS.Location = New-Object System.Drawing.Point(5,325)
$btn_OS.Size = New-Object System.Drawing.Size(145,25)
$btn_OS.Font = $Font
$btn_OS.Text = "OS"
$btn_OS.Add_Click($OS_info)
$MainForm.Controls.Add($btn_OS)

$btn_Keyboard = New-Object System.Windows.Forms.Button
$btn_Keyboard.Location = New-Object System.Drawing.Point(5,350)
$btn_Keyboard.Size = New-Object System.Drawing.Size(145,25)
$btn_Keyboard.Font = $Font
$btn_Keyboard.Text = "Keyboard"
$btn_Keyboard.Add_Click($Keyboard_info)
$MainForm.Controls.Add($btn_Keyboard)

$btn_Mouse = New-Object System.Windows.Forms.Button
$btn_Mouse.Location = New-Object System.Drawing.Point(5,375)
$btn_Mouse.Size = New-Object System.Drawing.Size(145,25)
$btn_Mouse.Font = $Font
$btn_Mouse.Text = "Mouse"
$btn_Mouse.Add_Click($Mouse_info)
$MainForm.Controls.Add($btn_Mouse)

$btn_CDROM = New-Object System.Windows.Forms.Button
$btn_CDROM.Location = New-Object System.Drawing.Point(5,400)
$btn_CDROM.Size = New-Object System.Drawing.Size(145,25)
$btn_CDROM.Font = $Font
$btn_CDROM.Text = "CDROM"
$btn_CDROM.Add_Click($CDROM_info)
$MainForm.Controls.Add($btn_CDROM)

$btn_Sound = New-Object System.Windows.Forms.Button
$btn_Sound.Location = New-Object System.Drawing.Point(5,425)
$btn_Sound.Size = New-Object System.Drawing.Size(145,25)
$btn_Sound.Font = $Font
$btn_Sound.Text = "Sound"
$btn_Sound.Add_Click($Sound_info)
$MainForm.Controls.Add($btn_Sound)

$btn_Printers = New-Object System.Windows.Forms.Button
$btn_Printers.Location = New-Object System.Drawing.Point(5,450)
$btn_Printers.Size = New-Object System.Drawing.Size(145,25)
$btn_Printers.Font = $Font
$btn_Printers.Text = "Printers"
$btn_Printers.Add_Click($Printers_info)
$MainForm.Controls.Add($btn_Printers)

$btn_Fan = New-Object System.Windows.Forms.Button
$btn_Fan.Location = New-Object System.Drawing.Point(5,475)
$btn_Fan.Size = New-Object System.Drawing.Size(145,25)
$btn_Fan.Font = $Font
$btn_Fan.Text = "Fan"
$btn_Fan.Add_Click($Fan_info)
$MainForm.Controls.Add($btn_Fan)

$btn_Battery = New-Object System.Windows.Forms.Button
$btn_Battery.Location = New-Object System.Drawing.Point(5,500)
$btn_Battery.Size = New-Object System.Drawing.Size(145,25)
$btn_Battery.Font = $Font
$btn_Battery.Text = "Battery"
$btn_Battery.Add_Click($Battery_info)
$MainForm.Controls.Add($btn_Battery)

$btn_PortBattery = New-Object System.Windows.Forms.Button
$btn_PortBattery.Location = New-Object System.Drawing.Point(5,525)
$btn_PortBattery.Size = New-Object System.Drawing.Size(145,25)
$btn_PortBattery.Font = $Font
$btn_PortBattery.Text = "Port Battery"
$btn_PortBattery.Add_Click($PortBattery_info)
$MainForm.Controls.Add($btn_PortBattery)

$btn_Software = New-Object System.Windows.Forms.Button
$btn_Software.Location = New-Object System.Drawing.Point(5,550)
$btn_Software.Size = New-Object System.Drawing.Size(145,25)
$btn_Software.Font = $Font
$btn_Software.Text = "Software"
$btn_Software.Add_Click($Software_info)
$MainForm.Controls.Add($btn_Software)

$btn_Process = New-Object System.Windows.Forms.Button
$btn_Process.Location = New-Object System.Drawing.Point(5,575)
$btn_Process.Size = New-Object System.Drawing.Size(145,25)
$btn_Process.Font = $Font
$btn_Process.Text = "Process"
$btn_Process.Add_Click($Process_info)
$MainForm.Controls.Add($btn_Process)

$btn_Services = New-Object System.Windows.Forms.Button
$btn_Services.Location = New-Object System.Drawing.Point(5,600)
$btn_Services.Size = New-Object System.Drawing.Size(145,25)
$btn_Services.Font = $Font
$btn_Services.Text = "Services"
$btn_Services.Add_Click($Services_info)
$MainForm.Controls.Add($btn_Services)

$btn_Ping = New-Object System.Windows.Forms.Button
$btn_Ping.Location = New-Object System.Drawing.Point(5,625)
$btn_Ping.Size = New-Object System.Drawing.Size(145,25)
$btn_Ping.Font = $Font
$btn_Ping.Text = "Ping Test"
$btn_Ping.Add_Click($Ping_Test_info)
$MainForm.Controls.Add($btn_Ping)

$btn_NetStat = New-Object System.Windows.Forms.Button
$btn_NetStat.Location = New-Object System.Drawing.Point(5,650)
$btn_NetStat.Size = New-Object System.Drawing.Size(145,25)
$btn_NetStat.Font = $Font
$btn_NetStat.Text = "NetStat"
$btn_NetStat.Add_Click($NetStat)
$MainForm.Controls.Add($btn_NetStat)

$btn_RDP = New-Object System.Windows.Forms.Button
$btn_RDP.Location = New-Object System.Drawing.Point(5,675)
$btn_RDP.Size = New-Object System.Drawing.Size(145,25)
$btn_RDP.Font = $Font
$btn_RDP.Text = "RDP"
$btn_RDP.Add_Click($RDP_Connection)
$MainForm.Controls.Add($btn_RDP)

$btn_Export = New-Object System.Windows.Forms.Button
$btn_Export.Location = New-Object System.Drawing.Point(5,700)
$btn_Export.Size = New-Object System.Drawing.Size(145,25)
$btn_Export.Font = $Font
$btn_Export.Text = "Export"
$btn_Export.Add_Click($Export)
$MainForm.Controls.Add($btn_Export)

$MainForm.ShowDialog()
}
