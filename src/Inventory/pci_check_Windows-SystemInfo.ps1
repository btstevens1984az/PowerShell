# Purpose: pci_check_Windows-SystemInfo — Hardware and software inventory collection.
# ***************************************************************************
# Windows Script
#  allow passing remote host to run against for remote collection
#  v.21 - hostname_#filename#.csv
# ***************************************************************************

## take a param of the remote computer to connect, fall back to SELF if not 
##  provided, allows for calling for data collection with list of hosts in
##  for
param (
    #[parameter(Mandatory=$true)] [string] $computerName,  ## need to have remote computer passed in
    [parameter(Mandatory=$true)] [System.IO.FileInfo] $iFile, ## need to have the input file list of hosts
    [string] $output = "$env:USERPROFILE\Desktop\pci-output" ## if path not passed, use current user desktop
)

clear 

# Quick and Dirty error handling will fine tune after functional
$ErroractionPreference = "SilentlyContinue"

## check for the folder, create if needed
If (-not (Test-Path -LiteralPath $output)) {
    Try { 
        New-Item -Path $output -ItemType Directory -ErrorAction Stop | Out-Null
    }
    Catch {
        Write-Warning "[!] Output directory does not exist, and unable to create ($output).`n $_" -ErrorAction Stop
        Exit  ## exiting
    }
    Write-Host "[+] Created output folder $output where files will be stored"
}
Else {
    Write-Host "[+] Output folder $output already exists.  Any files may be overwritten"
}

$inputFile = get-item($iFile) ## take the passed param and get the full path
if (Test-Path $inputFile) {
    foreach($computerName in [System.IO.File]::ReadLines($inputFile)) {
        Write-Host "processing collection on $computerName`r`n"
        ## try and connect to the remote host, terminate if not responding
        $liveCheck = $null
        Try {
            $liveCheck = Test-Connection -ComputerName $computerName -Quiet -ErrorAction Stop -Count 2
            if (! $liveCheck) { 
                Write-Warning "[!] Could not test connection to host ($computerName).  Terminating script"
                #Exit
                Continue
            }
        }
        Catch {
            $ErrMsg = $_.Exception.Message
            Write-Warning "[!] Error in network connectivity check to $computerName`n$ErrMsg"
            #Exit
            Continue
        }

        # IP Addresses
        $IPFile = New-Item -Path $output -Name $computerName"_IPFile.csv" -Force -ItemType "file" # System Information Out File
        $IPFileEntry = '"IP"' + ","
        $IPFileEntry = $IPFileEntry + '"' + "Family" + '"'
        $IPFileEntry | Out-File $IPFile -encoding ASCII -append

        ## get host information
        [System.Net.Dns]::GetHostAddresses($computerName) | Foreach-object {
            $AddFam = $_.AddressFamily
            $Add6Multi = $_.IsIPv6Multicast
            $Add6Link = $_.IsIPv6LinkLocal
            $Add6Site = $_.IsIPv6SiteLocal
            $AddStr = $_.IPAddressToString
            #Write IP record
            $IPInfoEntry = '"' + $AddStr + '"' + ","
            $IPInfoEntry = $IPInfoEntry + '"' + $AddFam + '"'
            $IPInfoEntry | Out-File $IPFile -encoding ASCII -append}

        # System Information File Out
        $SysFile = New-Item -Path $output -Name $computerName"_SysInfo.csv" -Force -ItemType "file" # System Information Out File
        $SysInfoEntry = '"System"'
        # $SysInfoEntry = $SysInfoEntry + "," + '"IP"'
        $SysInfoEntry = $SysInfoEntry + "," + '"AV Name"'
        $SysInfoEntry = $SysInfoEntry + "," + '"AV Exe"'
        $SysInfoEntry = $SysInfoEntry + "," + '"AV Definition"'
        $SysInfoEntry = $SysInfoEntry + "," + '"AV Real Time"'
        $SysInfoEntry = $SysInfoEntry + "," + '"OS Version"'
        $SysInfoEntry = $SysInfoEntry + "," + '"Domain"'
        $SysInfoEntry = $SysInfoEntry + "," + '"Crash Dump"'
        $SysInfoEntry = $SysInfoEntry + "," + '"CD Auto Run"'
        $SysInfoEntry = $SysInfoEntry + "," + '"Time Server"'
        $SysInfoEntry = $SysInfoEntry + "," + '"Firewall Dom"'
        $SysInfoEntry = $SysInfoEntry + "," + '"Firewall Pub"'
        $SysInfoEntry = $SysInfoEntry + "," + '"Firewall Stand"'
        $SysInfoEntry = $SysInfoEntry + "," + '"Restrict Anonymous"'
        $SysInfoEntry = $SysInfoEntry + "," + '"RM Max Idle Time"'
        $SysInfoEntry = $SysInfoEntry + "," + '"RM Inherit"'
        $SysInfoEntry = $SysInfoEntry + "," + '"Min Encrypt"'
        $SysInfoEntry = $SysInfoEntry + "," + '"Screen Saver Secure"'
        $SysInfoEntry = $SysInfoEntry + "," + '"Screen Saver Timeout"'
        $SysInfoEntry = $SysInfoEntry + "," + '"Pwd History"'
        $SysInfoEntry = $SysInfoEntry + "," + '"Pwd Max Age"'
        $SysInfoEntry = $SysInfoEntry + "," + '"Pwd Min Length"'
        $SysInfoEntry = $SysInfoEntry + "," + '"Pwd Complexity"'
        $SysInfoEntry = $SysInfoEntry + "," + '"Pwd Lock Out"'
        $SysInfoEntry = $SysInfoEntry + "," + '"Bad Login Lock"'
        $SysInfoEntry = $SysInfoEntry + "," + '"Guest Disabled"'
        $SysInfoEntry = $SysInfoEntry + "," + '"Admin Renamed"'
        $SysInfoEntry = $SysInfoEntry + "," + '"No LM Hash"'
        $SysInfoEntry = $SysInfoEntry + "," + '"NTLMv2 Req"'
        $SysInfoEntry = $SysInfoEntry + "," + '"Clear Pagefile"'
        $SysInfoEntry = $SysInfoEntry + "," + '"Network Everyone"'
        $SysInfoEntry | Out-File $SysFile -encoding ASCII -append # Write Header
        #********************************************************

        # Patch File Out
        $PFile = New-Item -Path $output -Name $computerName"_PatchInfo.csv" -Force -ItemType "file" # Patch Information Out File
        $PatchEntry = '"System"' # Server/System
        $PatchEntry = $PatchEntry + "," + '"Patch ID"'
        $PatchEntry = $PatchEntry + "," + '"Patch Description"'
        $PatchEntry = $PatchEntry + "," + '"Patch Date"'
        $PatchEntry | Out-File $PFile -encoding ASCII -append
        #****************************************************

        # Services File Out
        $SFile = New-Item -Path $output -Name $computerName"_SvcInfo.csv" -Force -ItemType "file" # Service Information Out File
        $ServiceEntry = '"System"' # Server/System
        $ServiceEntry = $ServiceEntry + "," + '"Status"'
        $ServiceEntry = $ServiceEntry + "," + '"Service"'
        $ServiceEntry = $ServiceEntry + "," + '"Service Display Name"'
        $ServiceEntry | Out-File $SFile -encoding ASCII -append
        #******************************************************

        # Shares File Out
        $SHFile = New-Item -Path $output -Name $computerName"_ShareInfo.csv" -Force -ItemType "file" # Share Information Out File
        $ShareEntry = '"System"'   # Server/System
        $ShareEntry = $ShareEntry + "," + '"Name"'
        $ShareEntry = $ShareEntry + "," + '"Path"'
        $ShareEntry = $ShareEntry + "," + '"Description"'
        $ShareEntry | Out-File $ShFile -encoding ASCII -append
        #*****************************************************

        # Application Versions File Out
        $AppFile = New-Item -Path $output -Name $computerName"_AppInfo.csv" -Force -ItemType "file" # App Versions Information Out File
        $AppEntry = '"System"'  # Server/System
        $AppEntry = $AppEntry + "," + '"Application"'
        $AppEntry = $AppEntry + "," + '"Vendor"'
        $AppEntry = $AppEntry + "," + '"Description"'
        $AppEntry = $AppEntry + "," + '"Version"'
        $AppEntry = $AppEntry + "," + '"InstallDate"'
        $AppEntry | Out-File $AppFile -encoding ASCII -append
        #****************************************************

        # Disk File Out
        $DiskFile1 = New-Item -Path $output -Name $computerName"_DiskInfo.csv" -Force -ItemType "file" # Disk Information Out File
        $DiskEntry = '"System"'  # Server/System
        $DiskEntry = $DiskEntry + "," + '"Disk Name"'
        $DiskEntry = $DiskEntry + "," + '"Disk Vol"'
        $DiskEntry = $DiskEntry + "," + '"File Sys"'
        $DiskEntry = $DiskEntry + "," + '"Disk Size"'
        $DiskEntry = $DiskEntry + "," + '"Disk Free"'
        $DiskEntry | Out-File $DiskFile1 -encoding ASCII -append
        #******************************************************

        # Log Permisions
        $LogFile = New-Item -Path $output -Name $computerName"_LogInfo.csv" -Force -ItemType "file" # Disk Information Out File
        $LogEntry = '"System"'   # Server/System
        $LogEntry = $LogEntry + "," + '"' + $LogName + '"'
        $LogEntry = $LogEntry + "," + '"' + $LogType + '"'
        $LogEntry = $LogEntry + "," + '"' + $LogSize + '"'
        $LogEntry = $LogEntry + "," + '"' + $LogMax + '"'
        $LogEntry = $LogEntry + "," + '"' + $LogMode + '"'
        $LogEntry = $LogEntry + "," + '"' + $LogPath + '"'
        $LogEntry = $LogEntry + "," + '"' + $LogSec + '"'

        $LogEntry | Out-File $LogFile -encoding ASCII -append
        #****************************************************

        # Processes Running File Out
        $PsFile = New-Item -Path $output -Name $computerName"_PsInfo.csv" -Force -ItemType "file" # Running Processes Information Out File
        $ProcessEntry = '"System"'
        $ProcessEntry = $ProcessEntry + "," + '"Process ID"'
        $ProcessEntry = $ProcessEntry + "," + '"Process Name"'
        $ProcessEntry | Out-File $PsFile -encoding ASCII -append
        #*******************************************************

        # Accounts
        $AcctFile = New-Item -Path $output -Name $computerName"_AcctInfo.csv" -Force -ItemType "file" # Local Accounts Information Out File
        $AcctEntry = '"System"'   # Server/System
        $AcctEntry = $AcctEntry + "," + '"Name"'
        $AcctEntry = $AcctEntry + "," + '"Disabled"'
        $AcctEntry = $AcctEntry + "," + '"Locked"'
        $AcctEntry = $AcctEntry + "," + '"Status"'
        $AcctEntry = $AcctEntry + "," + '"Full Name"'
        $AcctEntry = $AcctEntry + "," + '"Description"'
        $AcctEntry | Out-File $AcctFile -encoding ASCII -append
        #******************************************************

        # Groups
        $GrpFile = New-Item -Path $output -Name $computerName"_GrpInfo.csv" -Force -ItemType "file" # Local Accounts Information Out File
        $GroupEntry = '"System"'   # Server/System
        $GroupEntry = $GroupEntry + "," + '"Group"'
        $GroupEntry = $GroupEntry + "," + '"User"'
        $GroupEntry | Out-File $GrpFile -encoding ASCII -append

        # Network Adapters
        $NetFile = New-Item -Path $output -Name $computerName"_NetInfo.csv" -Force -ItemType "file" # Network Adapter Information Out File
        $NetEntry = '"System"' # Server/System
        $NetEntry = $NetEntry + "," + '"Connection Type"'
        $NetEntry = $NetEntry + "," + '"Connection Name"'
        $NetEntry = $NettEntry + "," + '"Enabled"'
        $NetEntry | Out-File $NetFile -encoding ASCII -append
        #**************************************************

        # Audit Polciy
        $AudFile = New-Item -Path $output -Name $computerName"_AudInfo.csv" -Force -ItemType "file" # Audit Information Out File
        $AudEntry = '"System"'
        $AudEntry = $AudEntry + "," + '"Policy"'
        $AudEntry = $AudEntry + "," + '"Setting"'
        $AudEntry | Out-File $AudFile -encoding ASCII -append
        #*****************************************************

        # **************************************************************
        # * End of Prep output files (Update these as items are added) *
        # **************************************************************
            "Processing System: " + $computerName
            $NBSys = Get-WmiObject win32_computersystem -ComputerName $computerName
            $NBName = $NBSys.Name # Get actual computer name

            # Appliction Versions
            ## local access, not what we need
            ##Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | ForEach-Object {
            Get-WMIObject -Class win32_product -ComputerName $computerName | ForEach-Object { 
            $AppN = $_.DisplayName
            $AppVend = $_.Publisher
            $AppD = $_.Comments
            $AppVer = $_.DisplayVersion
            $AppIDate = $_.InstallDate
            $AppEntry = '"' + $computerName + '"'  # Server/System
            $AppEntry = $AppEntry + "," + '"' + $AppN + '"'
            $AppEntry = $AppEntry + "," + '"' + $AppVend + '"'
            $AppEntry = $AppEntry + "," + '"' + $AppD + '"'
            $AppEntry = $AppEntry + "," + '"' + $AppVer + '"'
            $AppEntry = $AppEntry + "," + '"' + $AppIDate + '"'
            $AppEntry | Out-File $AppFile -encoding ASCII -append
            }#***************************************************

            # File Systems
            Get-WmiObject -Class win32_logicaldisk -ComputerName $computerName | ForEach-Object {
            $DiskName = $_.Name
            $DiskVol = $_.VolumeName
            $DiskFile = $_.FileSystem
            $DiskSize = $_.Size
            $DiskFree = $_.Freespace
            $DiskEntry = '"' + $computerName + '"'  # Server/System
            $DiskEntry = $DiskEntry + "," + '"' + $DiskName + '"'
            $DiskEntry = $DiskEntry + "," + '"' + $DiskVol + '"'
            $DiskEntry = $DiskEntry + "," + '"' + $DiskFile + '"'
            $DiskEntry = $DiskEntry + "," + '"' + $DiskSize + '"'
            $DiskEntry = $DiskEntry + "," + '"' + $DiskFree + '"'
            $DiskEntry | Out-File $DiskFile1 -encoding ASCII -append
            }#******************************************************

            # Windows Event Logs
            $l = Get-WinEvent -ComputerName $computerName -ListLog * | ForEach-Object {
            $LogName = $_.Name
            $LogType = $_.LogType
            $LogSize = $_.FileSize
            $LogMax = $_.MaximumSizeInBytes
            $LogMode = $_.LogMode
            $LogPath = $_.LogFilePath
            $LogSec = $_.SecurityDescriptor
            $LogEntry = '"' + $computerName + '"'   # Server/System
            $LogEntry = $LogEntry + "," + '"' + $LogName + '"'
            $LogEntry = $LogEntry + "," + '"' + $LogType + '"'
            $LogEntry = $LogEntry + "," + '"' + $LogSize + '"'
            $LogEntry = $LogEntry + "," + '"' + $LogMax + '"'
            $LogEntry = $LogEntry + "," + '"' + $LogMode + '"'
            $LogEntry = $LogEntry + "," + '"' + $LogPath + '"'
            $LogEntry = $LogEntry + "," + '"' + $LogSec + '"'
            $LogEntry | Out-File $LogFile -encoding ASCII -append
            }#***************************************************


            # Services On Host
            get-service -ComputerName $computerName | foreach-object{
            $ServiceEntry = '"' + $computerName + '"'   # Server/System
            $ServiceEntry = $ServiceEntry + "," + '"' + $_.status + '"'
            $ServiceEntry = $ServiceEntry + "," + '"' + $_.name + '"'
            $ServiceEntry = $ServiceEntry + "," + '"' + $_.displayname + '"'
            $ServiceEntry | Out-File $SFile -encoding ASCII -append
            }#*****************************************************

            # Processes On Host
            get-process -ComputerName $computerName | foreach-object{
            $ProcessEntry = '"' + $computerName + ","
            $ProcessEntry = $ProcessEntry + "," + '"' + $_.Id + '"'
            $ProcessEntry = $ProcessEntry + "," + '"' + $_.ProcessName + '"'
            $ProcessEntry | Out-File $PsFile -encoding ASCII -append
            }#******************************************************

            # Patches on host
            get-hotfix -ComputerName $computerName | foreach-object{
            $PatchEntry = '"' + $computerName + '"'
            $PatchEntry = $PatchEntry + "," + '"' + $_.hotfixid + '"'
            $PatchEntry = $PatchEntry + "," + '"' + $_.description + '"'
            $PatchEntry = $PatchEntry + "," + '"' + $_.installedon + '"'
            $PatchEntry | Out-File $PFile -encoding ASCII -append
            }#***************************************************

            # Shares on host
            get-WmiObject -ComputerName $computerName -class win32_share | foreach-object {
            $ShareEntry = '"' + $computerName + '"' # Server/System
            $ShareEntry = $ShareEntry + "," + '"' + $_.name + '"'
            $ShareEntry = $ShareEntry + "," + '"' + $_.path + '"'
            $ShareEntry = $ShareEntry + "," + '"' + $_.description + '"'
            $ShareEntry | Out-File $ShFile -encoding ASCII -append
            }#****************************************************


            # ************************
            # System Settings/Services
            # ************************

            # AntiVirus
            $AntiVirusProduct = Get-WmiObject -Namespace root/SecurityCenter2 -Class AntiVirusProduct -ComputerName $computerName
            #Switch to determine the status of antivirus definitions and real-time protection.
            #The values in this switch-statement are retrieved from the following website:
            # http://community.kaseya.com/resources/m/knowexch/1020.aspx
            ##
            ## detailed informaiton for Cylance deployments can also be found in the Status.json file
            ##  found in \ProgramData\Cylance\Status\Status.json
            ## 
            switch ($AntiVirusProduct.productState) {
                "262144" {$defstatus = "Up to date" ;$rtstatus = "Disabled"}
                "262160" {$defstatus = "Out of date" ;$rtstatus = "Disabled"}
                "266240" {$defstatus = "Up to date" ;$rtstatus = "Enabled"}
                "266256" {$defstatus = "Out of date" ;$rtstatus = "Enabled"}
                "393216" {$defstatus = "Up to date" ;$rtstatus = "Disabled"}
                "393232" {$defstatus = "Out of date" ;$rtstatus = "Disabled"}
                "393488" {$defstatus = "Out of date" ;$rtstatus = "Disabled"}
                "397312" {$defstatus = "Up to date" ;$rtstatus = "Enabled"}
                "397328" {$defstatus = "Out of date" ;$rtstatus = "Enabled"}
                "397584" {$defstatus = "Out of date" ;$rtstatus = "Enabled"}
                default {$defstatus = "Unknown" ;$rtstatus = "Unknown"}
            }
            $AvName = $AntiVirusProduct.displayName
            $AvExe = $AntiVirusProduct.pathToSignedProductExe
            #************************************************

            ## connection to remote registry
            $RegCon = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive] "LocalMachine",$computerName)
            # OS Name
            $RegSubKeySM = $RegCon.OpenSubKey("software\\212.228.214.64\\windows nt\\currentversion")
            $RegvOSVer = $RegSubkeySM.GetValue("ProductName")

            # Time Server
            $t = Get-Service -ComputerName $computerName -Name "w32time"
            if ($t.status -eq "Running") {
                $TimeServer = w32tm /query /computer:$computerName /source
            }
            else {
                $TimeServer = "Not Running"
            }


            # Firewall Enabled
            $RegSubKeySM = $RegCon.OpenSubKey("system\\46.164.29.244\\171.246.22.128\\7.236.118.161\\167.121.101.137\\95.48.79.75\\DomainProfile")
            $RegvFireDom = $RegSubKeySM.GetValue("EnableFirewall")
            $RegSubKeySM = $RegCon.OpenSubKey("system\\46.164.29.244\\171.246.22.128\\7.236.118.161\\167.121.101.137\\95.48.79.75\\PublicProfile")
            $RegvFirePub = $RegSubKeySM.GetValue("EnableFirewall")
            $RegSubKeySM = $RegCon.OpenSubKey("system\\46.164.29.244\\171.246.22.128\\7.236.118.161\\167.121.101.137\\95.48.79.75\\StandardProfile")
            $RegvFireStand = $RegSubKeySM.GetValue("EnableFirewall")

            # Crash Dump Enabled
            $RegSubKeySM = $RegCon.OpenSubKey("system\\46.164.29.244\\171.201.54.20\\crashcontrol")
            $RegvDDump = $RegSubKeySM.GetValue("CrashDumpEnabled")
            # CDROM AutoRun
            $RegSubKeySM = $RegCon.OpenSubKey("system\\46.164.29.244\\171.246.22.128\\cdrom")
            $RegvCDARun = $RegSubKeySM.GetValue("AutoRun")
            # Protect Registry
            $RegSubKeySM = $RegCon.OpenSubKey("system\\46.164.29.244\\171.201.54.20\\LSA")
            $RegvRestAn = $RegSubKeySM.GetValue("RestrictAnonymous")

            # Remote Access
            <# $Remote Info MaxIdle = (Get-ItemProperty -Path $keyRemote -Name MaxIdleTime).MaxIdleTime
            Remote Sessions:
            $keyRemote = & 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'
            MaxIdleTime -> Maximum idle time in seconds for user sessions.
            This value becomes effective only if you set the fInheritMaxIdleTime flag to 0.#>
            $RegSubKeySM = $RegCon.OpenSubKey("system\\46.164.29.244\\171.201.54.20\\terminal server\\101.224.114.198\\rdp-tcp")
            $RegvRMIdle = $RegSubkeySM.GetValue("MaxIdleTime")
            $RegvRMInherit = $RegSubKeySM.GetValue("fInheritMaxIdleTime")
            $RegvRMMinEncrypt = $RegSubKeySM.GetValue("MinEncryptionLevel")
            # LAN Manager Hash
            $RegSubKeySM = $RegCon.OpenSubKey("system\\46.164.29.244\\171.201.54.20\\LSA")
            $RegvNoLMHash = $RegSubkeySM.GetValue("NoLMHash")
            if ($RegvNoLMHash -eq 1)
              {$RegvNoLMHash = $true}
              else
              {$RegvNoLMHash = $false}
            # Network Security NTLMv2 only
            $RegvReqNTLM2 = $RegSubKeySM.GetValue("LmCompatibilityLevel") # 5 is NTLMv2 only https://technet.microsoft.com/en-us/library/cc960646.aspx
              <# if ($RegvReqNTLM2 -eq 5)
              {$RegvReqNTLM2 = $True}
              else
              {$RegvReqNTLM2 = $false}
             #>

            # Network Everyone Permission Apply to Anonymous (disable->0) should be false
            $RegvNetEvery = $RegSubkeySM.GetValue("Everyoneincludesanonymous")
            if ($RegvNetEvery -eq 1)
              {$RegvNetEvery = $True}
              else
              {$RegvNetEvery = $False}
            # Clear Virtual Memory - Shutdown
            $RegSubKeySM = $RegCon.OpenSubKey("system\\46.164.29.244\\171.201.54.20\\session manager\\memory management")
            $RegvClrPage = $RegSubkeySM.GetValue("ClearPageFileAtShutdown")
            if ($RegvClrPage -eq 1)
              {$RegvClrPage = $True}
              else
              {$RegvClrPage = $False}

            # Move to different hive HKCU
            $RegCon = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]`
            "CurrentUser",$computerName)

            # No wireless config
            Get-WmiObject -class win32_networkadapter -ComputerName $computerName -filter "netenabled='True'" | foreach-object {
            $NetvConID = _.netconnectionid
            $NetvName = _.name
            $NetvEnabled = _.netenabled
            $NetEntry = '"' + $computerName + '"' # Server/System
            $NetEntry = $NetEntry + "," + '"' + $_.netconnectionid + '"'
            $NetEntry = $NetEntry + "," + '"' + $_.name + '"'
            $NetEntry = $NetEntry + "," + '"' + $_.netenabled + '"'
            $NetEntry | Out-File $NetFile -encoding ASCII -append
            } #**************************************************

            # Screen Saver
            $RegSubKeySM = $RegCon.OpenSubKey("control panel\Desktop")
            $RegvScrs = $RegSubKeySM.GetValue("ScreenSaverIsSecure")
            $RegvScrt = $RegSubKeySM.GetValue("ScreenSaveTimeout")

            # Disabled Guest
            $Guest = get-wmiobject -class win32_useraccount -ComputerName $computerName -filter "name='Guest'"
            $Guest = $Guest.Disabled

            # Rename Administrator
            $AdminRen = $null
            # $AdminRen = Get-WmiObject -class win32_useraccount -ComputerName $computerName -filter "name='Administrator'")
            if (get-wmiobject -class win32_useraccount -ComputerName $computerName -filter "name='Administrator'")
              {
              $AdminRen = $False
              }


            # Local Accounts
            get-WmiObject -ComputerName $computerName -class win32_useraccount -Namespace "root\cimv2" -Filter "LocalAccount='$True'"| foreach-object{
            $AcctEntry = '"' + $computerName + '"' # Server/System
            $AcctEntry = $AcctEntry + "," + '"' + $_.name + '"'
            $AcctEntry = $AcctEntry + "," + '"' + $_.disabled + '"'
            $AcctEntry = $AcctEntry + "," + '"' + $_.lockout + '"'
            $AcctEntry = $AcctEntry + "," + '"' + $_.status + '"'
            $AcctEntry = $AcctEntry + "," + '"' + $_.fullname + '"'
            $AcctEntry = $AcctEntry + "," + '"' + $_.description + '"'
            $AcctEntry | Out-File $AcctFile -encoding ASCII -append
            }#**********************************************************

            # Groups
            $computer = [ADSI]"WinNT://$computerName,computer"
            $computer.psbase.children | where { $_.psbase.schemaClassName -eq 'group' } |
              foreach {
                $groupname = $_.name
                $group =[ADSI]$_.psbase.Path
                $group.psbase.Invoke("Members") |
                  foreach {
                    $member = $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
                    $GroupEntry = '"' + $computerName + '"' # Server/System
                    $GroupEntry = $GroupEntry + "," + '"' + $groupname + '"'
                    $GroupEntry = $GroupEntry + "," + '"' + $member + '"'
                    $GroupEntry | Out-File $GrpFile -encoding ASCII -append
                  }
              }


            # ***********************************************************
            # Security Parameters use rsop if part of domain else secedit for non-domain systems and domain controllers

            # Check if system is a Domain Controller
            $IsDC = $False
            $CompConfig = Get-WmiObject win32_computersystem -ComputerName $computerName
            $DRole = $CompConfig.DomainRole
            if ($DRole -eq 5) {$IsDC = $True}

            if ((Get-WmiObject win32_computersystem -ComputerName $computerName).partofdomain -eq $true -And $IsDC -ne $True) {
            # ***********************************************************
            # Run RSOP and pull data from XML result to get actual settings for system
            $gpFile = "{0}\{1}_gpresult.xml" -f $output,$computerName ## easier build then use ....
            gpresult /S $computerName /X "$gpFile" /F

            [xml]$filecontents = Get-Content -Path "$gpFile"

            #$Dom = $filecontents.rsop.ComputerResults.Domain **1-4-15 George Mateaki - inconsistent results.
            $Dom = (Get-WmiObject win32_computersystem -ComputerName $computerName).domain

            $inED = 0
            $inc = 0 # Array index, number of settings can vary in Account area

              $RsopLockOut = 0 # Initialize variable, values will be held from prior run
              $RsopPMaxAge = 0 # Initialize variable, values will be held from prior run
              $RsopLockBad = 0 # Initialize variable, values will be held from prior run
              $RsopPhist = 0 # Initialize variable, values will be held from prior run
              $RsopPLength = 0 # Initialize variable, values will be held from prior run
              $RsopPComplx = $null # Initialize variable, values will be held from prior run

              #Traverse Each ExtensioinData as XML location changes for some reason
              $filecontents.rsop.ComputerResults.ExtensionData | ForEach-Object {
                $filecontents.rsop.ComputerResults.ExtensionData[$inED].extension.account | ForEach-Object {
                    switch ($filecontents.rsop.ComputerResults.ExtensionData[$inED].extension.account[$inc].name) {
                        # "MaxRenewAge" {}
                        "LockoutDuration" {
                            $RsopLockOut = $filecontents.rsop.ComputerResults.ExtensionData[$inED].extension.account[$inc].SettingNumber
                        }
                        "MaximumPasswordAge" {
                            $RsopPMaxAge = $filecontents.rsop.ComputerResults.ExtensionData[$inED].extension.account[$inc].SettingNumber
                        }
                        # "MinimumPasswordAge" {}
                        # "ResetLockoutCount" {}
                        # "MaxServiceAge" {}
                        "LockoutBadCount" {
                            $RsopLockBad = $filecontents.rsop.ComputerResults.ExtensionData[$inED].extension.account[$inc].SettingNumber
                        }
                        # "MaxClockSkew" {}
                        # "MaxTicketAge" {}
                        "PasswordHistorySize" {
                            $RsopPhist = $filecontents.rsop.ComputerResults.ExtensionData[$inED].extension.account[$inc].SettingNumber
                        }
                        "MinimumPasswordLength" {
                            $RsopPLength = $filecontents.rsop.ComputerResults.ExtensionData[$inED].extension.account[$inc].SettingNumber
                        }
                        "PasswordComplexity" {
                            $RsopPComplx = $filecontents.rsop.ComputerResults.ExtensionData[$inED].extension.account[$inc].SettingBoolean
                        }
                        # "ClearTestPassword" {}
                        # "TicketValidateClient" {}
                        # default {}
                    } # End Switch
                    $inc = $inc + 1 # Increment index, next item in accounts
                } # End ForEach-object
                $inc = 0
                $inED = $inED + 1
              } # End ExtensionData ForEachObject
           ############################################################################
            } else {
                $sF = "{0}\{1}_cfg.ini" -f $output,$computerName
                $sFL = "{0}\{1}_cfg.log" -f $output,$computerName
                SecEdit /export /cfg "$sF" /log "$sFL" ## easier build then use ....
        
                # $locsec = get-content cfg.ini
                # $MinPasAge = $locsec | select-string "MinimumPasswordAge"
                # $RsopPLength = right($MinPasAge,len($MinPasAge) - 21))

                Get-Content "$sF" | Foreach-Object {
                    if ($_.Startswith("LockoutDuration")) {
                        $pass = $_.Split('=')
                        $RsopLockOut = $pass[1]
                    }
                    if ($_.Startswith("MaximumPasswordAge")) {
                        $pass = $_.Split('=')
                        $RsopPMaxAge = $pass[1]
                    }
                    if ($_.Startswith("LockoutBadCount")) {
                        $pass = $_.Split('=')
                        $RsopLockBad = $pass[1]
                    }
                    if ($_.Startswith("PasswordHistorySize")) {
                        $pass = $_.Split('=')
                        $RsopPHist = $pass[1]
                    }
                    if ($_.Startswith("MinimumPasswordLength")) {
                        $pass = $_.Split('=')
                        $RsopPLength = $pass[1]
                    }
                    if ($_.Startswith("PasswordComplexity")) {
                        $pass = $_.Split('=')
                        $RsopPComplx = $pass[1]
                    }
                 } # End of foreach-object
            } # End of if on Domain or not


            # Audit Policy
#              $AudPol = auditpol /get /category:*
#              $IncA = 0
#              $AudPol | ForEach-Object {
#                  $AudItem = $AudPol.getvalue($IncA)
#                  $IncA = $IncA + 1
#                  if ($auditem.startswith("  ")) {
#                    $APItemLen = $AudItem.Length
#                    $AudPolItem = $Auditem.Substring(2,40)
#                    $AudPolSet = $Auditem.Substring(42)
#                    $AudEntry = '"' + $computerName + '"'
#                    $AudEntry = $AudEntry + "," + '"' + $AudPolItem + '"'
#                    $AudEntry = $AudEntry + "," + '"' + $AudPolSet + '"'
#                    $AudEntry | Out-File $AudFile -encoding ASCII -append
#                  }
#              } # End for each $AudPol
            #*****************************************************

            # Write out record for the current server
            $SysInfoEntry = '"' + $computerName + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $AvName + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $AvExe + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $defstatus + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $rtStatus + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $RegvOSVer + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $Dom + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $RegvDDump + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $RegvCDARun + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $TimeServer + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $RegvFireDom + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $RegvFirePub + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $RegvFireStand + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $RegvRestAn + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $RegvRMIdle + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $RegvRMInherit + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $RegvRMMinEncrypt + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $RegvScrs + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $RegvScrt + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $RsopPhist + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $RsopPMaxAge + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $RsopPLength + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $RsopPComplx + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $RsopLockOut + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $RsopLockBad + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $Guest + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $AdminRen + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $RegvNoLMHash + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $RegvReqNTLM2 + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $RegvClrPage + '"'
            $SysInfoEntry = $SysInfoEntry + "," + '"' + $RegvNetEvery + '"'
            $SysInfoEntry | Out-File $SysFile -encoding ASCII -append

        # Clean Up
        $RegCon.Close()
        $RegCon.Dispose()
        "Script Complete on $computerName"
    } ## end foreach...$computerName
}
else {
    Write-Error "[!] Input file ($iFile) is not accessible"
    Exit
}