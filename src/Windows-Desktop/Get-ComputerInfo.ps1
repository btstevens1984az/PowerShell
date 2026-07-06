Function Get-ComputerInfo 
{ 
<# 
.SYNOPSIS 
        This function will collect various data elements from a local or remote computer. 
.DESCRIPTION 
        This function was inspired by Get-ServerInfo a custom function written by Jason Walker  
        and the PSInfo Sysinternals Tool written by Mark Russinovich.  It will collect a plethora 
        of data elements that are important to a Microsoft Windows System Administrator.  The  
        function will run locally, run without the -ComputerName 184.69.141.83, or connect remotely  
        via the -ComputerName 206.240.131.195  This function will return objects that you can interact  
        with, however, due to the fact that multiple custom objects are returned, when piping the  
        function to Get-Member, it will only display the first object, unless you run the following;  
        "Get-ComputerInfo | Foreach-Object {$_ | Get-Member}".  This function is currently in beta.   
        current PowerShell console: ". .\Get-ComputerInfo.ps1"  Then it can be run as a "cmdlet"  
        aka "function".  Reminder: In it's current state, this function's output is intended for  
        the console, in other words the data does not export very well, unless the Foreach-Object  
        technique is used above.  This is something that may come in a future release or a simplied  
        version. 
.PARAMETER ComputerName 
        A single Computer or an array of computer names.  The default is localhost ($env:COMPUTERNAME). 
.EXAMPLE 
        PS D:\> Get-ComputerInfo -ComputerName 119.59.69.242 
 
        Computer            : LAP01 
        Domain              : WILHITE.DS 
        OperatingSystem     : Microsoft Windows 8 Enterprise 
        OSArchitecture      : 64-bit 
        BuildNumber         : 9200 
        ServicePack         : 0 
        Manufacturer        : Microsoft Corporation 
        Model               : Virtual Machine 
        SerialNumber        : 123456789 
        Processor           : Intel(R) Xeon(R) CPU E5-2670 0 @ 2.60GHz 
        LogicalProcessors   : 2 
        PhysicalMemory      : 8192 
        OSReportedMemory    : 8187 
        PAEEnabled          : False 
        InstallDate         : 8/16/2012 7:44:31 PM 
        LastBootUpTime      : 3/6/2013 8:44:57 AM 
        UpTime              : 04:32:17.1965808 
        RebootPending       : False 
        RebootPendingKey    : False 
        CBSRebootPending    : False 
        WinUpdRebootPending : False 
 
        NetAdapterName  : Microsoft Virtual Machine Bus Network Adapter 
        NICManufacturer : Microsoft 
        DHCPEnabled     : False 
        MACAddress      : 00:15:5D:01:05:5D 
        IPAddress       : {174.213.71.147} 
        IPSubnetMask    : {81.227.230.216} 
        DefaultGateway  : {56.194.250.50} 
        DNSServerOrder  : {140.67.180.101, 48.250.98.249} 
        DNSSuffixSearch : {wilhite.ds} 
        PhysicalAdapter : True 
        Speed           : 10000 Mbit 
 
        DeviceID    : C: 
        VolumeName  : OS 
        VolumeDirty : False 
        Size        : 24.90 GB 
        FreeSpace   : 14.21 GB 
        PercentFree : 57.05 % 
 
        DeviceID    : D: 
        VolumeName  : Data 
        VolumeDirty : False 
        Size        : 100.00 GB 
        FreeSpace   : 61.66 GB 
        PercentFree : 61.66 % 
.LINK 
        Registry Class 
        http://msdn.microsoft.com/en-us/library/microsoft.win32.registry.aspx 
 
        Win32_BIOS 
        http://msdn.microsoft.com/en-us/library/windows/desktop/aa394077(v=vs.85).aspx 
 
        Win32_ComputerSystem 
        http://msdn.microsoft.com/en-us/library/windows/desktop/aa394102(v=vs.85).aspx 
 
        Win32_OperatingSystem 
        http://msdn.microsoft.com/en-us/library/windows/desktop/aa394239(v=vs.85).aspx 
 
        Win32_NetworkAdapter 
        http://msdn.microsoft.com/en-us/library/windows/desktop/aa394216(v=vs.85).aspx 
 
        Win32_NetworkAdapterConfiguration 
        http://msdn.microsoft.com/en-us/library/windows/desktop/aa394217(v=vs.85).aspx 
 
        Win32_Processor 
        http://msdn.microsoft.com/en-us/library/windows/desktop/aa394373(v=vs.85).aspx 
 
        Win32_PhysicalMemory 
        http://msdn.microsoft.com/en-us/library/windows/desktop/aa394347(v=vs.85).aspx 
 
        Win32_LogicalDisk 
        http://msdn.microsoft.com/en-us/library/windows/desktop/aa394173(v=vs.85).aspx 
 
        Component-Based Servicing 
        http://technet.microsoft.com/en-us/library/cc756291(v=WS.10).aspx 
 
        PendingFileRename/Auto Update: 
        http://support.microsoft.com/kb/2723674 
        http://technet.microsoft.com/en-us/library/cc960241.aspx 
        http://blogs.msdn.com/b/hansr/archive/2006/02/17/patchreboot.aspx 
 
        SCCM 2012/CCM_ClientSDK: 
        http://msdn.microsoft.com/en-us/library/jj902723.aspx 
        Email:     bwilhite1@carolina.rr.com 
        Date:      03/31/2012 
        RevDate:   08/29/2012 
        PoShVer:   2.0/3.0 
        ScriptVer: 0.86 (Beta) 
        0.86 - Code clean-up, now a bit easier to read 
               Added several PendingReboot properites 
               RebootPendingKey - Shows contents of files pending rename 
               CBSRebootPending - Component-Based Servicing, see link above 
               WinUpdRebootPending - Pending Reboot due to Windows Update 
               Added PAEEnabled Property 
        0.85 - Now reports LogicalProcessors & Domain (2K3/2K8) 
               Better PendingReboot support for Windows 2008+ 
               Minor Write-Progress Changes 
                    
#> 
 
[CmdletBinding()] 
param( 
  [Parameter(Position=0,ValueFromPipeline=$true)] 
  [Alias("CN","Computer")] 
  [String[]]$ComputerName="$env:COMPUTERNAME" 
  ) 
 
Begin 
  { 
    $i=0 
    #Adjusting ErrorActionPreference to stop on all errors 
    $TempErrAct = $ErrorActionPreference 
    $ErrorActionPreference = "Stop" 
     
    #Defining $CompInfo Select Properties For Correct Display Order 
    $CompInfoSelProp = @( 
      "Computer" 
      "Domain" 
      "OperatingSystem" 
      "OSArchitecture" 
      "BuildNumber" 
      "ServicePack" 
      "Manufacturer" 
      "Model" 
      "SerialNumber" 
      "Processor" 
      "LogicalProcessors" 
      "PhysicalMemory" 
      "OSReportedMemory" 
      "PAEEnabled" 
      "InstallDate" 
      "LastBootUpTime" 
      "UpTime" 
      "RebootPending" 
      "RebootPendingKey" 
      "CBSRebootPending" 
            "WinUpdRebootPending" 
      )#End $CompInfoSelProp 
     
    #Defining $NetInfo Select Properties For Correct Display Order 
    $NetInfoSelProp = @( 
      "NICName" 
      "NICManufacturer" 
      "DHCPEnabled" 
      "MACAddress" 
      "IPAddress" 
      "IPSubnetMask" 
      "DefaultGateway" 
      "DNSServerOrder" 
      "DNSSuffixSearch" 
      "PhysicalAdapter" 
      "Speed" 
      )#End $NetInfoSelProp 
     
    #Defining $VolInfo Select Properties For Correct Display Order 
    $VolInfoSelProp = @( 
      "DeviceID" 
      "VolumeName" 
      "VolumeDirty" 
      "Size" 
      "FreeSpace" 
      "PercentFree" 
      )#End $VolInfoSelProp 
       
  }#End Begin Script Block 
 
Process 
  { 
    Foreach ($Computer in $ComputerName) 
      { 
        Try 
          { 
            If ($ComputerName.Count -gt 1) 
              { 
                #Setting up Main Write-Progress Process, If Querying More Than 1 Computer. 
                $WriteProgParams = @{ 
                  Id=1 
                  Activity="Processing Get-ComputerInfo For $Computer" 
                  Status="Percent Complete: $([int]($i/($ComputerName.Count)*100))%" 
                  PercentComplete=[int]($i++/($ComputerName.Count)*100) 
                  }#End $WriteProgParam Hashtable     
                Write-Progress @WriteProgParams 
              }#End If ($ComputerName.Count -gt 1) 
                         
            #Gathering WMI Data 
            $n,$d = 0,8 
            Write-Progress -ParentId 1 -Activity "Collecting Data: Win32_Processor" -Status "Percent Complete: $([int](($n/$d)*100))%" -PercentComplete (($n/$d)*100);$n++ 
            $WMI_PROC = Get-WmiObject -Class Win32_Processor -ComputerName $Computer 
                         
            Write-Progress -ParentId 1 -Activity "Collecting Data: Win32_BIOS" -Status "Percent Complete: $([int](($n/$d)*100))%" -PercentComplete (($n/$d)*100);$n++ 
            $WMI_BIOS = Get-WmiObject -Class Win32_BIOS -ComputerName $Computer 
 
            Write-Progress -ParentId 1 -Activity "Collecting Data: Win32_ComputerSystem" -Status "Percent Complete: $([int](($n/$d)*100))%" -PercentComplete (($n/$d)*100);$n++ 
            $WMI_CS = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Computer 
 
            Write-Progress -ParentId 1 -Activity "Collecting Data: Win32_OperatingSystem" -Status "Percent Complete: $([int](($n/$d)*100))%" -PercentComplete (($n/$d)*100);$n++ 
            $WMI_OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer 
 
            Write-Progress -ParentId 1 -Activity "Collecting Data: Win32_PhysicalMemory" -Status "Percent Complete: $([int](($n/$d)*100))%" -PercentComplete (($n/$d)*100);$n++ 
            $WMI_PM = Get-WmiObject -Class Win32_PhysicalMemory -ComputerName $Computer 
 
            Write-Progress -ParentId 1 -Activity "Collecting Data: Win32_LogicalDisk" -Status "Percent Complete: $([int](($n/$d)*100))%" -PercentComplete (($n/$d)*100);$n++ 
            $WMI_LD = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType = '3'" -ComputerName $Computer 
                         
            Write-Progress -ParentId 1 -Activity "Collecting Data: Win32_NetworkAdapter" -Status "Percent Complete: $([int](($n/$d)*100))%" -PercentComplete (($n/$d)*100);$n++ 
            $WMI_NA = Get-WmiObject -Class Win32_NetworkAdapter -ComputerName $Computer 
                         
            Write-Progress -ParentId 1 -Activity "Collecting Data: Win32_NetworkAdapter" -Status "Percent Complete: $([int](($n/$d)*100))%" -PercentComplete (($n/$d)*100);$n++ 
            $WMI_NAC = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled=$true" -ComputerName $Computer 
 
            #Connecting to the Registry to determine PendingReboot status. 
            Write-Progress -ParentId 1 -Activity "Collecting Data: Registry Query" -Status "Percent Complete: $([int](($n/$d)*100))%" -PercentComplete (($n/$d)*100);$n++ 
            $RegCon = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"LocalMachine",$Computer) 
 
            #If Windows Vista & Above, CBS Will Not Write To The PFRO Reg Key, Query CBS Key For "RebootPending" Key. 
            #Also, since there are properties that are exclusive to 2K8+ marking "Unaval" for computers below 2K8. 
            $WinBuild = $WMI_OS.BuildNumber 
                        $CBSRebootPend,$RebootPending = $false,$false 
            If ($WinBuild -ge 6001) 
              { 
                #Querying the Component Based Servicing reg key for pending reboot status. 
                $RegSubKeysCBS  = $RegCon.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\").GetSubKeyNames() 
                $CBSRebootPend  = $RegSubKeysCBS -contains "RebootPending" 
 
                #Values that are present in 2K8+ 
                $OSArchitecture = $WMI_OS.OSArchitecture 
                $LogicalProcs   = $WMI_CS.NumberOfLogicalProcessors 
           
              }#End If ($WinBuild -ge 6001) 
            Else 
              { 
                #Win32_OperatingSystem does not have a value for OSArch in 2K3 & Below 
                $OSArchitecture = "**Unavailable**" 
 
                #In order to gather processor count for 2K3 & Below, Win32_Processor Instance Count is needed. 
                If ($WMI_PROC.Count -gt 1) 
                  { 
                    $LogicalProcs = $WMI_PROC.Count 
                  }#End If ($WMI_PROC.Count -gt 1) 
                Else 
                  { 
                    $LogicalProcs = 1 
                  }#End Else 
 
              }#End Else 
             
            #Querying Session Manager for both 2K3 & 2K8 for the PendingFileRenameOperations REG_MULTI_SZ to set PendingReboot value. 
            $RegSubKeySM      = $RegCon.OpenSubKey("SYSTEM\CurrentControlSet\Control\Session Manager\") 
            $RegValuePFRO     = $RegSubKeySM.GetValue("PendingFileRenameOperations",$false) 
 
            #Querying WindowsUpdate\Auto Update for both 2K3 & 2K8 for "RebootRequired" 
            $RegWindowsUpdate = $RegCon.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\").GetSubKeyNames() 
            $WUAURebootReq    = $RegWindowsUpdate -contains "RebootRequired" 
            $RegCon.Close() 
             
            #Setting the $RebootPending var based on data read from the PendingFileRenameOperations REG_MULTI_SZ and CBS Key.   
            If ($CBSRebootPend -or $RegValuePFRO -or $WUAURebootReq) 
              { 
                $RebootPending = $true 
              }#End If ($RegValuePFRO -eq "NoValue") 
             
            #Calculating Memory, Converting InstallDate, LastBootTime, Uptime. 
            [int]$Memory  = ($WMI_PM | Measure-Object -Property Capacity -Sum).Sum / 1MB 
            $InstallDate  = ([WMI]'').ConvertToDateTime($WMI_OS.InstallDate) 
            $LastBootTime = ([WMI]'').ConvertToDateTime($WMI_OS.LastBootUpTime) 
            $UpTime       = New-TimeSpan -Start $LastBootTime -End (Get-Date) 
             
            #PAEEnabled is only valid on x86 systems, setting value to false first. 
            $PAEEnabled = $false 
            If ($WMI_OS.PAEEnabled) 
              { 
                $PAEEnabled = $true 
              } 
             
            #Creating the $CompInfo Object 
            New-Object PSObject -Property @{ 
              Computer            = $WMI_CS.Name 
              Domain              = $WMI_CS.Domain.ToUpper() 
              OperatingSystem     = $WMI_OS.Caption 
              OSArchitecture      = $OSArchitecture 
              BuildNumber         = $WinBuild 
              ServicePack         = $WMI_OS.ServicePackMajorVersion 
              Manufacturer        = $WMI_CS.Manufacturer 
              Model               = $WMI_CS.Model 
              SerialNumber        = $WMI_BIOS.SerialNumber 
              Processor           = ($WMI_PROC | Select-Object -ExpandProperty Name -First 1) 
              LogicalProcessors   = $LogicalProcs 
              PhysicalMemory      = $Memory 
              OSReportedMemory    = [int]$($WMI_CS.TotalPhysicalMemory / 1MB) 
              PAEEnabled          = $PAEEnabled 
              InstallDate         = $InstallDate 
              LastBootUpTime      = $LastBootTime 
              UpTime              = $UpTime 
              RebootPending       = $RebootPending 
              RebootPendingKey    = $RegValuePFRO 
              CBSRebootPending    = $CBSRebootPend 
                            WinUpdRebootPending = $WUAURebootReq 
              } | Select-Object $CompInfoSelProp 
             
            #There may be multiple NICs that have IPAddresses, hence the Foreach loop. 
            Foreach ($NAC in $WMI_NAC) 
              { 
                #Getting properties from $WMI_NA that correlate to the matched Index, this is faster than using $WMI_NAC.GetRelated('Win32_NetworkAdapter').  
                $NetAdap = $WMI_NA | Where-Object {$NAC.Index -eq $_.Index} 
                 
                #Since there are properties that are exclusive to 2K8+ marking "Unaval" for computers below 2K8. 
                If ($WinBuild -ge 6001) 
                  { 
                    $PhysAdap = $NetAdap.PhysicalAdapter 
                    $Speed    = "{0:0} Mbit" -f $($NetAdap.Speed / 1000000) 
                  }#End If ($WinBuild -ge 6000) 
                Else 
                  { 
                    $PhysAdap = "**Unavailable**" 
                    $Speed    = "**Unavailable**" 
                  }#End Else 
 
                #Creating the $NetInfo Object 
                New-Object PSObject -Property @{ 
                  NICName         = $NetAdap.Name 
                  NICManufacturer = $NetAdap.Manufacturer 
                  DHCPEnabled     = $NAC.DHCPEnabled 
                  MACAddress      = $NAC.MACAddress 
                  IPAddress       = $NAC.IPAddress 
                  IPSubnetMask    = $NAC.IPSubnet 
                  DefaultGateway  = $NAC.DefaultIPGateway 
                  DNSServerOrder  = $NAC.DNSServerSearchOrder 
                  DNSSuffixSearch = $NAC.DNSDomainSuffixSearchOrder 
                  PhysicalAdapter = $PhysAdap 
                  Speed           = $Speed 
                  } | Select-Object $NetInfoSelProp 
 
              }#End Foreach ($NAC in $WMI_NAC) 
               
            #There may be multiple Volumes, hence the Foreach loop.   
            Foreach ($Volume in $WMI_LD) 
              { 
                #Creating the $VolInfo Object 
                New-Object PSObject -Property @{ 
                  DeviceID    = $Volume.DeviceID 
                  VolumeName  = $Volume.VolumeName 
                  VolumeDirty = $Volume.VolumeDirty 
                  Size        = $("{0:F} GB" -f $($Volume.Size / 1GB)) 
                  FreeSpace   = $("{0:F} GB" -f $($Volume.FreeSpace / 1GB)) 
                  PercentFree = $("{0:P}" -f $($Volume.FreeSpace / $Volume.Size)) 
                  } | Select-Object $VolInfoSelProp 
 
              }#End Foreach ($Volume in $WMI_LD) 
 
          }#End Try 
 
        Catch 
          { 
            Write-Warning "$_" 
          }#End Catch 
 
      }#End Foreach ($Computer in $ComputerName) 
 
  }#End Process 
   
End 
  { 
    #Resetting ErrorActionPref 
    $ErrorActionPreference = $TempErrAct 
  }#End End 
 
}#End Function Get-ComputerInfo