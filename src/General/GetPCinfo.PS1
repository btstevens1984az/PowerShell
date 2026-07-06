# Purpose: GetPCinfo — General-purpose PowerShell utilities.
# PowerShell2
# Kerry K
# GetPCinfo.PS1
# Get PC Info 
 
function Pause ($Message="Press any key to continue..."){
    ""
    Write-Host $Message
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
 
function GetCompName{
    $compname = Read-Host "Enter a computer name or IP"
    CheckHost
}
 
function CheckHost{
    $ping = gwmi Win32_PingStatus -filter "Address='$compname'"
    if($ping.StatusCode -eq 0){$pcip=$ping.ProtocolAddress; GetMenu}
    else{Pause "Host $compname down...Press any key to continue"; GetCompName}
}
 
function GetMenu {
    Clear-Host
    "  /----------------------\"
    "  |     ADC SERVER/PC INFO TOOL     |"
    "  \----------------------/"
    "  $compname ($pcip)"
    ""
    ""
    "1) PC Serial Number"
    "2) PC Printer Info"
    "3) Current User"
    "4) OS Info"
    "5) System Info"
    "6) Add/Remove Program List"
    "7) Process List"
    "8) Service List"
    "9) USB Devices"
    "10) Uptime"
    "11) Disk Space"
    "12) Memory Info"
    "13) Processor Info"
    "14) Monitor Serial Numbers"
    ""
    "C) Change Computer Name"
    "X) Exit The program"
    ""
    $MenuSelection = Read-Host "Enter Selection"
    GetInfo
}
 
function GetInfo{
    Clear-Host
    switch ($MenuSelection){
        1 { #PC Serial Number
            gwmi -computer $compname Win32_BIOS | Select-Object SerialNumber | Format-List
            Pause
            CheckHost
          }
 
        2 { #PC Printer Information
            gwmi -computer $compname Win32_Printer | Select-Object DeviceID,DriverName, PortName | Format-List
            Pause
            CheckHost
          }
 
        3 { #Current User
            gwmi -computer $compname Win32_ComputerSystem | Format-Table @{Expression={$_.Username};Label="Current User"}
            ""
            #May take a very long time if on a domain with many users
            #"All Users"
            #"------------"
            #gwmi -computer $compname Win32_UserAccount | foreach{$_.Caption}
            Pause
            CheckHost
          }
 
        4 { #OS Info
            gwmi -computer $compname Win32_OperatingSystem | Format-List @{Expression={$_.Caption};Label="OS Name"},SerialNumber,OSArchitecture
            Pause
            CheckHost
          }
 
        5 { #System Info
            gwmi -computer $compname Win32_ComputerSystem | Format-List Name,Domain,Manufacturer,Model,SystemType
            Pause
            CheckHost
          }        
 
        6 { #Add/Remove Program List
            gwmi -computer $compname Win32_Product | Sort-Object Name | Format-Table Name,Vendor,Version
            Pause
            CheckHost
          }
 
        7 { #Process Listx
 
            gwmi -computer $compname Win32_Process | Select-Object Caption,Handle | Sort-Object Caption | Format-Table
            Pause
            CheckHost
          }
 
        8 { #Service List
            gwmi -computer $compname Win32_Service | Select-Object Name,State,Status,StartMode,ProcessID, ExitCode | Sort-Object Name | Format-Table
            Pause
            CheckHost
          }
 
        9 { #USB Devices
            gwmi -computer $compname Win32_USBControllerDevice | %{[wmi]($_.Dependent)} | Select-Object Caption, Manufacturer, DeviceID | Format-List
            Pause
            CheckHost
          }
 
        10 { #Uptime
            $wmi = gwmi -computer $compname Win32_OperatingSystem
            $localdatetime = $wmi.ConvertToDateTime($wmi.LocalDateTime)
            $lastbootuptime = $wmi.ConvertToDateTime($wmi.LastBootUpTime)
 
            "Current Time:      $localdatetime"
            "Last Boot Up Time: $lastbootuptime"
 
            $uptime = $localdatetime - $lastbootuptime
            ""
            "Uptime: $uptime"
            Pause
            CheckHost
          }
        11 { #Disk Info
            $wmi = gwmi -computer $compname Win32_logicaldisk
            foreach($device in $wmi){
                    Write-Host "Drive: " $device.name
                    Write-Host -NoNewLine "Size: "; "{0:N2}" -f ($device.Size/1Gb) + " Gb"
                    Write-Host -NoNewLine "FreeSpace: "; "{0:N2}" -f ($device.FreeSpace/1Gb) + " Gb"
                    ""
             }
            Pause
            CheckHost
          }
        12 { #Memory Info
            $wmi = gwmi -computer $compname Win32_PhysicalMemory
            foreach($device in $wmi){
                Write-Host "Bank Label:     " $device.BankLabel
                Write-Host "Capacity:       " ($device.Capacity/1MB) "Mb"
                Write-Host "Data Width:     " $device.DataWidth
                Write-Host "Device Locator: " $device.DeviceLocator
                ""
            }
            Pause
            CheckHost
          }
        13 { #Processor Info
            gwmi -computer $compname Win32_Processor | Format-List Caption,Name,Manufacturer,ProcessorId,NumberOfCores,AddressWidth
            Pause
            CheckHost
          }
        14 { #Monitor Info
 
            #Turn off Error Messages
            $ErrorActionPreference_Backup = $ErrorActionPreference
            $ErrorActionPreference = "SilentlyContinue"
 
            $keytype=[Microsoft.Win32.RegistryHive]::LocalMachine
            if($reg=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($keytype,$compname)){
                #Create Table To Hold Info
                $montable = New-Object system.Data.DataTable "Monitor Info"
                #Create Columns for Table
                $moncol1 = New-Object system.Data.DataColumn Name,([string])
                $moncol2 = New-Object system.Data.DataColumn Serial,([string])
                $moncol3 = New-Object system.Data.DataColumn Ascii,([string])
                #Add Columns to Table
                $montable.columns.add($moncol1)
                $montable.columns.add($moncol2)
                $montable.columns.add($moncol3)
 
                $regKey= $reg.OpenSubKey("SYSTEM\\46.164.29.244\\61.190.134.178\DISPLAY" )
                $HID = $regkey.GetSubKeyNames()
                foreach($HID_KEY_NAME in $HID){
                    $regKey= $reg.OpenSubKey("SYSTEM\\46.164.29.244\\61.190.134.178\\17.160.77.217\\$HID_KEY_NAME" )
                    $DID = $regkey.GetSubKeyNames()
                    foreach($DID_KEY_NAME in $DID){
                        $regKey= $reg.OpenSubKey("SYSTEM\\46.164.29.244\\61.190.134.178\\17.160.77.217\\$HID_KEY_NAME\\$DID_KEY_NAME\\Device Parameters" )
                        $EDID = $regKey.GetValue("EDID")
                        foreach($int in $EDID){
                            $EDID_String = $EDID_String+([char]$int)
                        }
                        #Create new row in table
                        $monrow=$montable.NewRow()
 
                        #MonitorName
                        $checkstring = [char]0x00 + [char]0x00 + [char]0x00 + [char]0xFC + [char]0x00
                        $matchfound = $EDID_String -match "$checkstring([\w ]+)"
                        if($matchfound){$monrow.Name = [string]$matches[1]} else {$monrow.Name = '-'}
 
                        #Serial Number
                        $checkstring = [char]0x00 + [char]0x00 + [char]0x00 + [char]0xFF + [char]0x00
                        $matchfound =  $EDID_String -match "$checkstring(\S+)"
                        if($matchfound){$monrow.Serial = [string]$matches[1]} else {$monrow.Serial = '-'}
 
                        #AsciiString
                        $checkstring = [char]0x00 + [char]0x00 + [char]0x00 + [char]0xFE + [char]0x00
                        $matchfound = $EDID_String -match "$checkstring([\w ]+)"
                        if($matchfound){$monrow.Ascii = [string]$matches[1]} else {$monrow.Ascii = '-'}         
 
                        $EDID_String = ''
 
                        $montable.Rows.Add($monrow)
                    }
                }
                $montable | select-object  -unique Serial,Name,Ascii | Where-Object {$_.Serial -ne "-"} | Format-Table
            } else {
                Write-Host "Access Denied - Check Permissions"
            }
            $ErrorActionPreference = $ErrorActionPreference_Backup #Reset Error Messages
            Pause
            CheckHost
          }
        1337 { Write-Host "Custom Tool for ADC Use - 2010";Pause; CheckHost}
        c {Clear-Host;$compname="";GetCompName}
        x {Clear-Host; exit}
        default{CheckHost}
      }
}
 
#---------Start Main--------------
$compname = $args[0]
if($compname){CheckHost}
else{GetCompName}