<#
    .SYNOPSIS  
    The Get-PatchFestReport function is a set of Windows Management Instrumentation interface (WMI) scripts that investigators and forensic analysts can use to retrieve information from a 
    compromised (or potentially compromised) Windows system. The scripts use WMI to pull this information from the operating system. Therefore, this script will need to be executed with a 
    user that has the necessary privileges.  Reports are created while being amended and will consolidate to create a PivotChart in Excel.

        PatchFestReport.ps1 will retrieve the following data from an 
        individual machine or a group of systems:  
             
            - Autorun entries
            - Disk info
            - Environment variables
            - Event logs (10 latest)
            - Installed Software
            - Logon sessions
            - List of drivers
            - List of mapped network drives
            - List of running processes
            - Logged in user (disabled)
            - Local groups (disabled)
            - Local user accounts (disabled)
            - Network configuration
            - Network connections
            - Patches
            - Scheduled tasks with AT command
            - Shares
            - Services
            - System Information

    .EXAMPLE
    .\Get-PatchFestReport.ps1

    File Name      : PatchFestReport.ps1
    Prerequisite   : PowerShell
#>
Function Get-PatchFestReport { 
  [CmdletBinding()]
  param
  (
    [Switch] $PatchGroup1000,
    [Switch] $PatchGroup1001,
    [Switch] $PatchGroup1002,
    [Switch] $PatchGroup1003,
    [Switch] $PatchGroup1004,
    [Switch] $PatchGroup4,
    [Switch] $PatchGroup5,
    [Switch] $PatchGroup6,
    [Switch] $PatchGroup8,
    [Switch] $PatchGroup10
  )
  #Create Variables/Groups Install and Preload PowerShell Modules and start Logging
  Set-ExecutionPolicy -ExecutionPolicy 'RemoteSigned' -Force
  $ErrorActionPreference = 'SilentlyContinue'
  $MonthFormat = ((Get-Date).ToString('MM-MMMM'))
  $TimeStamp = Get-Date -Format o | foreach {$_ -replace ":", "."}
  $ConfirmPreference = High
  $DebugPreference = SilentlyContinue
  LogWrite
  #Install-Module -Name 'MergeCsv' -Force
  Import-Module -Name 'MergeCsv' -Force
  #Install-Module -Name 'ImportExcel' -Force
  Import-Module -Name 'ImportExcel' -Force
  #Install-Module -Name 'ActiveDirectory' -Force
  Import-Module -Name 'ActiveDirectory' -Force
  #Install-module -Name 'PowerShellLogging' -Force
  Import-module -Name 'PowerShellLogging' -Force
  # Function Name 'LogWrite' - Creates Logs from PowerShell Function
  <#function Find-Folders {
      [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
      [System.Windows.Forms.Application]::EnableVisualStyles()
      $browse = New-Object System.Windows.Forms.FolderBrowserDialog
      $browse.SelectedPath = "\\186.189.182.154\share"
      $browse.ShowNewFolderButton = $true
      $browse.Description = "Select a directory"
      $loop = $true
      while($loop)
      {
      if ($browse.ShowDialog() -eq "OK")
      {
      $loop = $false
		
      #Insert your script here
      } else
      {
      $res = [System.Windows.Forms.MessageBox]::Show("You clicked Cancel. Would you like to try again or exit?", "Select a location", [System.Windows.Forms.MessageBoxButtons]::RetryCancel)
      if($res -eq "Cancel")
      {
      #Ends script
      return
      }
      }
      }
      $browse.SelectedPath
      $browse.Dispose()
      } Find-Folders
  #>
  #Checks the current PatchFest directory to either create or change your current directory to the MM-YYYY folder in "\\186.189.182.154\share" "))
      $OutputEncoding = ASCIIEncoding object
      $ProgressPreference = Continue
      $PSDefaultParameterValues = (None - empty hash table)
      $PSModuleAutoLoadingPreference= All
      $PSSessionApplicationName = WSMAN
      $PSSessionConfigurationName = http://schemas.microsoft.com/PowerShell/microsoft.PowerShell
      $PSSessionOption = New-PSSessionOption -NoMachineProfile
      $VerbosePreference = Continue
      $WarningPreference = Inquire
  $WhatIfPreference = 0#>
  # Function Name 'LogWrite' - Creates Logs from PowerShell Function
  Function LogWrite{
      mkdir "\\186.189.182.154\share"
      $LogFile = Enable-LogFile -Path "\\186.189.182.154\share"
      Write-Host "Write-Host $env:USERNAME Performing PatchFestReport Logging at $TimeStamp" 
  }
  # Function Name 'ListComputers' - Takes entered domain and lists all Servers
  Function ListComputers
  {
    $DN = ""
    $Response = ""
    $DNSName = ""
    $DNSArray = ""
    $objSearcher = ""
    $colProplist = ""
    $objComputer = ""
    $objResults = ""
    $colResults = ""
    $Computer = ""
    $comp = ""
    New-Item -type file -force "$Script:Folder_Path\Computer_List_$Script:curDate.txt" | Out-Null
    $Script:Compute = "$Script:Folder_Path\Computer_List_$Script:curDate.txt"
    $strCategory = "(ObjectCategory=Computer)"
    Write-Host "Would you like to automatically pull from your domain or provide your own domain?"
    Write-Host "Auto pull uses the current domain you are on, if you need to select a different domain use manual."
    $response = Read-Host = "[1] Auto Pull, [2] Manual Selection"
    If($Response -eq "1") {
      $DNSName = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
      If($DNSName -ne $Null) {
        $DNSArray = $DNSName.Split(".") 
        for ($x = 0; $x -lt $DNSArray.Length ; $x++) {  
          if ($x -eq ($DNSArray.Length - 1)){$Separator = ""}else{$Separator =","} 
      [string]$DN += "DC=" + $DNSArray[$x] + $Separator  } }
      $Script:Domain = $DN
      echo "Pulled computers from: "$Script:Domain 
      $objSearcher = New-Object System.DirectoryServices.DirectorySearcher("LDAP://$Script:Domain")
      $objSearcher.Filter = $strCategory
      $objSearcher.PageSize = 100000
      $objSearcher.SearchScope = "SubTree"
      $colProplist = "name"
      foreach ($i in $colPropList) {
      $objSearcher.propertiesToLoad.Add($i) }
      $colResults = $objSearcher.FindAll()
      foreach ($objResult in $colResults) {
        $objComputer = $objResult.Properties
        $comp = $objComputer.name
      echo $comp | Out-File $Script:Compute -Append }
      $Script:Computers = (Get-Content $Script:Compute) | Sort-Object
    }
    elseif($Response -eq "2")
    {
      Write-Host "Would you like to automatically pull from your domain or provide your own domain?"
      Write-Host "Auto pull uses the current domain you are on, if you need to select a different domain use manual."
      $Script:Domain = Read-Host "Enter your Domain here: OU=PatchFest,ENTERPRISEOU=Groups,OU=PatchFest,DC=chw,DC=org"
      If ($Script:Domain -eq $Null) {Write-Host "You did not provide a valid response."; . ListComputers}
      echo "Pulled Server hostnames from: "$Script:Domain 
      $objOU = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$Script:Domain")
      $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
      $objSearcher.SearchRoot = $objOU
      $objSearcher.Filter = $strCategory
      $objSearcher.PageSize = 100000
      $objSearcher.SearchScope = "SubTree"
      $colProplist = "name"
      foreach ($i in $colPropList) { $objSearcher.propertiesToLoad.Add($i) }
      $colResults = $objSearcher.FindAll()
      foreach ($objResult in $colResults) {
        $objComputer = $objResult.Properties
        $comp = $objComputer.name
      echo $comp | Out-File $Script:Compute -Append }
      $Script:Computers = (Get-Content $Script:Computer) | Sort-Object
    }
    else {
      Write-Host "You did not supply a correct response, Please select a response." -foregroundColor Red
    . ListComputers }
  }
  # Function Name 'ListTextFile' - Enumerates Server Hostnames in a text file
  # Create a text file and enter the names of each Server. One Server
  # name per line. Supply the path to the text file when prompted.
  Function ListTextFile 
  {
    $file_Dialog = ""
    $file_Name = ""
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $file_Dialog = New-Object system.windows.forms.openfiledialog
    $file_Dialog.InitialDirectory = "$env:USERPROFILE"
    $file_Dialog.MultiSelect = $false
    $file_Dialog.showdialog()
    $file_Name = $file_Dialog.filename
    $Comps = Get-Content $file_Name
    If ($Comps -eq $Null) {
      Write-Host "Your file was empty. You must select a file with at least one Server hostname in it." -ForegroundColor Red
    . ListTextFile }
    Else
    {
      $Script:Computers = @()
      ForEach ($Comp in $Comps)
      {
        If ($Comp -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/\d{1,2}")
        {
          $Temp = $Comp.Split("/")
          $IP = $Temp[0]
          $Mask = $Temp[1]
          . Get-Subnet-Range $IP $Mask
          $Script:Computers += $Script:IPList
        }
        Else
        {
          $Script:Computers += $Comp
        }
      }  
    }
  }
  Function Get-Subnet-Range {
    #.Synopsis
    # Lists all IPs in a subnet.
    #.Example
    # Get-Subnet-Range -IP 201.195.50.33 -Netmask /24
    #.Example
    # Get-Subnet-Range -IP 31.98.21.129 -Netmask 209.48.232.144        
    Param(
      [string]
      $IP,
      [string]
      $netmask
    )  
    Begin {
      $IPs = New-Object System.Collections.ArrayList

      Function Get-NetworkAddress {
        #.Synopsis
        # Get the network address of a given lan segment
        #.Example
        # Get-NetworkAddress -IP 132.252.4.45 -mask 81.227.230.216
        Param (
          [string]
          $IP,
               
          [string]
          $Mask,
               
          [switch]
          $Binary
        )
        Begin {
          $NetAdd = $null
        }
        Process {
          $BinaryIP = ConvertTo-BinaryIP $IP
          $BinaryMask = ConvertTo-BinaryIP $Mask
          0..34 | %{
            $IPBit = $BinaryIP.Substring($_,1)
            $MaskBit = $BinaryMask.Substring($_,1)
            IF ($IPBit -eq '1' -and $MaskBit -eq '1') {
              $NetAdd = $NetAdd + "1"
            } elseif ($IPBit -eq ".") {
              $NetAdd = $NetAdd +'.'
            } else {
              $NetAdd = $NetAdd + "0"
            }
          }
          if ($Binary) {
            return $NetAdd
          } else {
            return ConvertFrom-BinaryIP $NetAdd
          }
        }
      }
      Function ConvertTo-BinaryIP {
        #.Synopsis
        # Convert an IP address to binary
        #.Example
        # ConvertTo-BinaryIP -IP 203.135.6.89
        Param (
          [string]
          $IP
        )
        Process {
          $out = @()
          Foreach ($octet in $IP.split('.')) {
            $strout = $null
            0..7|% {
              IF (($octet - [math]::pow(2,(7-$_)))-ge 0) {
                $octet = $octet - [math]::pow(2,(7-$_))
                [string]$strout = $strout + "1"
              } else {
                [string]$strout = $strout + "0"
              }  
            }
            $out += $strout
          }
          return [string]::join('.',$out)
        }
      }
      Function ConvertFrom-BinaryIP {
        #.Synopsis
        # Convert from Binary to an IP address
        #.Example
        # Convertfrom-BinaryIP -IP 11000000.10101000.00000001.00000001
        Param (
          [string]
          $IP
        )
        Process {
          $out = @()
          Foreach ($octet in $IP.split('.')) {
            $strout = 0
            0..7|% {
              $bit = $octet.Substring(($_),1)
              IF ($bit -eq 1) {
                $strout = $strout + [math]::pow(2,(7-$_))
              }
            }
            $out += $strout
          }
          return [string]::join('.',$out)
        }
      }
      Function ConvertTo-MaskLength {
        #.Synopsis
        # Convert from a netmask to the masklength
        #.Example
        # ConvertTo-MaskLength -Mask 81.227.230.216
        Param (
          [string]
          $mask
        )
        Process {
          $out = 0
          Foreach ($octet in $Mask.split('.')) {
            $strout = 0
            0..7|% {
              IF (($octet - [math]::pow(2,(7-$_)))-ge 0) {
                $octet = $octet - [math]::pow(2,(7-$_))
                $out++
              }
            }
          }
          return $out
        }
      }
      Function ConvertFrom-MaskLength {
        #.Synopsis
        # Convert from masklength to a netmask
        #.Example
        # ConvertFrom-MaskLength -Mask /24
        #.Example
        # ConvertFrom-MaskLength -Mask 24
        Param (
          [int]
          $mask
        )
        Process {
          $out = @()
          [int]$wholeOctet = ($mask - ($mask % 8))/8
          if ($wholeOctet -gt 0) {
            1..$($wholeOctet) |%{
              $out += "255"
            }
          }
          $subnet = ($mask - ($wholeOctet * 8))
          if ($subnet -gt 0) {
            $octet = 0
            0..($subnet - 1) | %{
              $octet = $octet + [math]::pow(2,(7-$_))
            }
            $out += $octet
          }
          for ($i=$out.count;$i -lt 4; $I++) {
            $out += 0
          }
          return [string]::join('.',$out)
        }
      }
      Function Get-IPRange {
        #.Synopsis
        # Given an Ip and subnet, return every IP in that lan segment
        #.Example
        # Get-IPRange -IP 132.252.4.45 -Mask 81.227.230.216
        #.Example
        # Get-IPRange -IP 121.141.34.111 -Mask /23
        Param (
          [string]
          $IP,
          [string]
          $netmask
        )
        Process {
          iF ($netMask.length -le 3) {
            $masklength = $netmask.replace('/','')
            $Subnet = ConvertFrom-MaskLength $masklength
          } else {
            $Subnet = $netmask
            $masklength = ConvertTo-MaskLength -Mask $netmask
          }
          $network = Get-NetworkAddress -IP $IP -Mask $Subnet
               
          [int]$FirstOctet,[int]$SecondOctet,[int]$ThirdOctet,[int]$FourthOctet = $network.split('.')
          $TotalIPs = ([math]::pow(2,(32-$masklength)) -2)
          $blocks = ($TotalIPs - ($TotalIPs % 256))/256
          if ($Blocks -gt 0) {
            1..$blocks | %{
              0..255 |%{
                if ($FourthOctet -eq 255) {
                  If ($ThirdOctet -eq 255) {
                    If ($SecondOctet -eq 255) {
                      $FirstOctet++
                      $secondOctet = 0
                    } else {
                      $SecondOctet++
                      $ThirdOctet = 0
                    }
                  } else {
                    $FourthOctet = 0
                    $ThirdOctet++
                  }  
                } else {
                  $FourthOctet++
                }
                Write-Output ("{0}.{1}.{2}.{3}" -f `
                $FirstOctet,$SecondOctet,$ThirdOctet,$FourthOctet)
              }
            }
          }
          $sBlock = $TotalIPs - ($blocks * 256)
          if ($sBlock -gt 0) {
            1..$SBlock | %{
              if ($FourthOctet -eq 255) {
                If ($ThirdOctet -eq 255) {
                  If ($SecondOctet -eq 255) {
                    $FirstOctet++
                    $secondOctet = 0
                  } else {
                    $SecondOctet++
                    $ThirdOctet = 0
                  }
                } else {
                  $FourthOctet = 0
                  $ThirdOctet++
                }  
              } else {
                $FourthOctet++
              }
              Write-Output ("{0}.{1}.{2}.{3}" -f `
              $FirstOctet,$SecondOctet,$ThirdOctet,$FourthOctet)
            }
          }
        }
      }
    }
    Process {
      #get every ip in scope
      Get-IPRange $IP $netmask | %{
        [void]$IPs.Add($_)
      }
      $Script:IPList = $IPs
    }
  }
  # Function Name 'SingleEntry' - Enumerates Server hostname from user input
  Function SingleEntry 
  {
    $Comp = Read-Host "Enter Server Hostname or IP (50.49.250.103) or IP Subnet (50.49.250.103/24)"
    Write-Host "Please wait while I create the reports"
    If ($Comp -eq $Null) { . SingleEntry }
    ElseIf ($Comp -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/\d{1,2}")
    {
      $Temp = $Comp.Split("/")
      $IP = $Temp[0]
      $Mask = $Temp[1]
      . Get-Subnet-Range $IP $Mask
      $Script:Computers = $Script:IPList
    }
    Else
    { $Script:Computers = $Comp}
  }
  # Function Name 'PatchGroup1000' - Enumerates Server hostname from Active Directory Group
  Function PatchGroup1000 
  {
    Write-Host "Please wait while I import the AD Groups Server Hostnames"
    $Comp = Get-ADGroupMember "PatchFest - Group 1000 Servers" | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name
    {
      $Temp = $Comp.Split("/")
      $IP = $Temp[0]
      $Mask = $Temp[1]
      . Get-Subnet-Range $IP $Mask
      $Script:Computers = $Script:IPList
    }
    Else
    { $Script:Computers = $Comp}
  }
  # Function Name 'PatchGroup1001' - Enumerates Server hostname from Active Directory Group
  Function PatchGroup1001 
  {
    Write-Host "Please wait while I import the AD Groups Server Hostnames"
    $Comp = Get-ADGroupMember "PatchFest - Group 1001 Servers" | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name
    {
      $Temp = $Comp.Split("/")
      $IP = $Temp[0]
      $Mask = $Temp[1]
      . Get-Subnet-Range $IP $Mask
      $Script:Computers = $Script:IPList
    }
    Else
    { $Script:Computers = $Comp}
  }
  # Function Name 'PatchGroup1002' - Enumerates Server hostname from Active Directory Group
  Function PatchGroup1002 
  {
    Write-Host "Please wait while I import the AD Groups Server Hostnames"
    $Comp = Get-ADGroupMember "PatchFest - Group 1002 Servers" | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name
    {
      $Temp = $Comp.Split("/")
      $IP = $Temp[0]
      $Mask = $Temp[1]
      . Get-Subnet-Range $IP $Mask
      $Script:Computers = $Script:IPList
    }
    Else
    { $Script:Computers = $Comp}
  }
  # Function Name 'PatchGroup1003' - Enumerates Server hostname from Active Directory Group
  Function PatchGroup1003
  {
    Write-Host "Please wait while I import the AD Groups Server Hostnames"
    $Comp = Get-ADGroupMember "PatchFest - Group 1003 Servers" | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name
    {
      $Temp = $Comp.Split("/")
      $IP = $Temp[0]
      $Mask = $Temp[1]
      . Get-Subnet-Range $IP $Mask
      $Script:Computers = $Script:IPList
    }
    Else
    { $Script:Computers = $Comp}
  }
  # Function Name 'PatchGroup1004' - Enumerates Server hostname from Active Directory Group
  Function PatchGroup1004
  {
    Write-Host "Please wait while I import the AD Groups Server Hostnames"
    $Comp = Get-ADGroupMember "PatchFest - Group 1004 Servers" | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name
    {
      $Temp = $Comp.Split("/")
      $IP = $Temp[0]
      $Mask = $Temp[1]
      . Get-Subnet-Range $IP $Mask
      $Script:Computers = $Script:IPList
    }
    Else
    { $Script:Computers = $Comp}
  }
  # Function Name 'PatchGroup4' - Enumerates Server hostname from Active Directory Group
  Function PatchGroup4
  {
    Write-Host "Please wait while I import the AD Groups Server Hostnames"
    $Comp = Get-ADGroupMember "PatchFest - Group 4 Servers" | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name
    {
      $Temp = $Comp.Split("/")
      $IP = $Temp[0]
      $Mask = $Temp[1]
      . Get-Subnet-Range $IP $Mask
      $Script:Computers = $Script:IPList
    }
    Else
    { $Script:Computers = $Comp}
  }
  # Function Name 'PatchGroup5' - Enumerates Server hostname from Active Directory Group
  Function PatchGroup5
  {
    Write-Host "Please wait while I import the AD Groups Server Hostnames"
    $Comp = Get-ADGroupMember "PatchFest - Group 5 Servers" | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name
    {
      $Temp = $Comp.Split("/")
      $IP = $Temp[0]
      $Mask = $Temp[1]
      . Get-Subnet-Range $IP $Mask
      $Script:Computers = $Script:IPList
    }
    Else
    { $Script:Computers = $Comp}
  }
  # Function Name 'PatchGroup6' - Enumerates Server hostname from Active Directory Group
  Function PatchGroup6
  {
    Write-Host "Please wait while I import the AD Groups Server Hostnames"
    $Comp = Get-ADGroupMember "PatchFest - Group 6 Servers" | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name
    {
      $Temp = $Comp.Split("/")
      $IP = $Temp[0]
      $Mask = $Temp[1]
      . Get-Subnet-Range $IP $Mask
      $Script:Computers = $Script:IPList
    }
    Else
    { $Script:Computers = $Comp}
  }
  # Function Name 'PatchGroup8' - Enumerates Server hostname from Active Directory Group
  Function PatchGroup8
  {
    Write-Host "Please wait while I import the AD Groups Server Hostnames"
    $Comp = Get-ADGroupMember "PatchFest - Group 8 Servers" | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name 
    {
      $Temp = $Comp.Split("/")
      $IP = $Temp[0]
      $Mask = $Temp[1]
      . Get-Subnet-Range $IP $Mask
      $Script:Computers = $Script:IPList
    }
    Else
    { $Script:Computers = $Comp}
  }
  # Function Name 'PatchGroup10' - Enumerates Server hostname from Active Directory Group
  Function PatchGroup10
  {
    Write-Host "Please wait while I import the AD Groups Server Hostnames"
    $Comp = Get-ADGroupMember "PatchFest - Group 10 Servers" | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name
    {
      $Temp = $Comp.Split("/")
      $IP = $Temp[0]
      $Mask = $Temp[1]
      . Get-Subnet-Range $IP $Mask
      $Script:Computers = $Script:IPList
    }
    Else
    { $Script:Computers = $Comp}
  }
  Write-Host "`n"
  Write-Host "`n"
  Write-Host "`n"
  Write-Host "`n"
  Write-Host "`n"
  Write-Host "`n"
  Write-Host "`n"
  Write-Host "`n"
  Write-Host "`n"
  Write-Host "`n"  
  Write-Host "        __________         __         .__    ___________              __      " -ForegroundColor Green
  Write-Host "        \______   \_____ _/  |_  ____ |  |__ \_   _____/___   _______/  |_    " -ForegroundColor Green
  Write-Host "         |     ___/\__  \\   __\/ ___\|  |  \ |    __)/ __ \ /  ___/\   __\   " -ForegroundColor Green
  Write-Host "         |    |     / __ \|  | \  \___|   Y  \|     \\  ___/ \___ \  |  |     " -ForegroundColor Green
  Write-Host "         |____|    (____  /__|  \___  >___|  /\___  / \___  >____  > |__|     " -ForegroundColor Green
  Write-Host "                        \/          \/     \/     \/      \/     \/           " -ForegroundColor Green
  Write-Host "                                                                              " -ForegroundColor Green
  Write-Host "`n"
  Write-Host "`n"
  Write-Host "`n"
  Write-Host "`n"
  Write-Host ""
  Write-Host "How would you like to import the Server hostnames?"	-ForegroundColor Yellow
  $strResponse = Read-Host "`n[1] All Domain Computers (Must provide Domain), `n[2] Computer names from a File, `n[3] List a Single Computer manually, `n[4] Add AD Group 'PatchGroup 1000 Hostnames', `n[5] Add AD Group 'PatchGroup 1001 Hostnames', `n[6] Add AD Group 'PatchGroup 1002 Hostnames', `n[7] Add AD Group 'PatchGroup 1003 Hostnames', `n[8] Add AD Group 'PatchGroup 1004 Hostnames', `n[9] Add AD Group 'PatchGroup 4 Hostnames', `n[10] Add AD Group 'PatchGroup 5 Hostnames', `n[11] Add AD Group 'PatchGroup 6 Hostnames', `n[12] Add AD Group 'PatchGroup 8 Hostnames', `n[13] Add AD Group 'PatchGroup 10 Hostnames' `n"
  If($strResponse -eq "1"){. ListComputers | Sort-Object}
  elseif($strResponse -eq "2"){. ListTextFile}
  elseif($strResponse -eq "3"){. SingleEntry}
  elseif($strResponse -eq "4"){. PatchGroup1000}
  elseif($strResponse -eq "5"){. PatchGroup1001}
  elseif($strResponse -eq "6"){. PatchGroup1002}
  elseif($strResponse -eq "7"){. PatchGroup1003}
  elseif($strResponse -eq "8"){. PatchGroup1004}
  elseif($strResponse -eq "9"){. PatchGroup4}
  elseif($strResponse -eq "10"){. PatchGroup5}
  elseif($strResponse -eq "11"){. PatchGroup6}
  elseif($strResponse -eq "12"){. PatchGroup8}
  elseif($strResponse -eq "13"){. PatchGroup10}
  else{Write-Host "You did not supply a correct response, `
  Please run script again."; pause -foregroundColor Red}
  Write-Host "Received Server hostnames(s)... Next task..." -ForegroundColor Yellow
  Set-Location -Path "\\186.189.182.154\share" -Passthru 
  mkdir "\\186.189.182.154\share" | Out-Null
  mkdir "\\186.189.182.154\share" | Out-Null
  # Autorun information
  Write-Host "Retrieving Autoruns information..." -ForegroundColor Yellow
  Get-WmiObject -Class win32_startupcommand -ComputerName $computers | select PSComputername, Name, Location, Command, User | Export-CSV "\\186.189.182.154\share" -Append -NoTypeInformation
  # Logon information
  Write-Host "Retrieving logon information..." -ForegroundColor Yellow
  Get-WmiObject -Class win32_networkloginprofile -ComputerName $computers | select PSComputername,Name, LastLogon,LastLogoff,NumberOfLogons,PasswordAge | Export-CSV "\\186.189.182.154\share" -Append -NoTypeInformation
  # Event log information (Note: If logs are not returning data, ensure the script 
  # is not ran from the ISE console)
  Write-Host "Retrieving event log information..." -ForegroundColor Yellow
  Get-WmiObject -Class win32_ntlogevent -ComputerName $computers | where {$_.LogFile -eq 'System'} | select PSComputername, LogFile, EventCode, TimeGenerated, Message, InsertionStrings, Type | select -first 10 | Export-CSV "\\186.189.182.154\share" -Append -NoTypeInformation
  Get-WmiObject -Class win32_ntlogevent -ComputerName $computers | where {$_.LogFile -eq 'Security'} | select PSComputername, LogFile, EventCode, TimeGenerated, Message, InsertionStrings, Type | select -first 10 | Export-CSV "\\186.189.182.154\share" -Append -NoTypeInformation
  Get-WmiObject -Class win32_ntlogevent -ComputerName $computers | where {$_.LogFile -eq 'Application'} | select PSComputername, LogFile, EventCode, TimeGenerated, Message, InsertionStrings, Type | select -first 10 | Export-CSV "\\186.189.182.154\share" -Append -NoTypeInformation
  # Driver information
  Write-Host "Retrieving driver information..." -ForegroundColor yellow
  Get-WmiObject -Class win32_systemdriver -ComputerName $computers | select PSComputername, Name, InstallDate, DisplayName, PathName, State, StartMode | Export-CSV "\\186.189.182.154\share" -Append -NoTypeInformation
  # Mapped drives information
  Write-Host "Retrieving mapped drives information..." -ForegroundColor yellow
  Get-WmiObject -Class win32_mappedlogicaldisk -ComputerName $computers | select PSComputername, Name, ProviderName | Export-CSV "\\186.189.182.154\share" -Append -NoTypeInformation
  # Process information
  Write-Host "Retrieving running processes information..." -ForegroundColor yellow
  Get-WmiObject -Class win32_process -ComputerName $computers | select PSComputername, Name, Description, ProcessID, ParentProcessID, Handle, HandleCount, ThreadCount, CreationDate | Export-CSV "\\186.189.182.154\share" -Append -NoTypeInformation
  # Scheduled tasks
  Write-Host "Retrieving scheduled tasks created by at.exe or Win32_ScheduledJob..." -ForegroundColor yellow
  Get-WmiObject -Class win32_scheduledjob -ComputerName $computers | select PSComputername, Name, Owner, JodID, Command, RunRepeatedly, InteractWithDesktop | Export-CSV "\\186.189.182.154\share" -Append -NoTypeInformation
  # Services
  Write-Host "Retrieving service information..." -ForegroundColor yellow
  Get-WmiObject -Class win32_service -ComputerName $computers | select PSComputername, ProcessID, Name, Description, PathName, Started, StartMode, StartName, State | Export-CSV "\\186.189.182.154\share" -Append -NoTypeInformation
  # Environment variables
  Write-Host "Retrieving Environment Variables Information..." -ForegroundColor yellow
  Get-WmiObject -Class win32_environment -ComputerName $computers | select PSComputername, UserName, Name, VariableValue | Export-CSV "\\186.189.182.154\share" -Append -NoTypeInformation
  # User information
  #Write-Host "Retrieving User Information..." -ForegroundColor yellow
  #Get-WmiObject -Class win32_useraccount -ComputerName $computers | select PSComputername, accounttype, name, fullname, domain, disabled, localaccount, lockout, passwordchangeable, passwordexpires, sid | Export-CSV "\\186.189.182.154\share" -Append -NoTypeInformation
  # Group information
  #Write-Host "Retrieving Group Information..." -ForegroundColor yellow
  #Get-WmiObject -Class win32_group -ComputerName $computers |select PSComputername, Caption, Domain, Name, Sid | Export-CSV "\\186.189.182.154\share" -Append -NoTypeInformation
  # Logged in user
  #Write-Host "Retrieving Logged On User Information..." -ForegroundColor yellow
  #Get-WmiObject -Class win32_computersystem -ComputerName $computers | select PSComputername, Username | Export-CSV "\\186.189.182.154\share" -Append -NoTypeInformation
  # Network settings
  Write-Host "Retrieving network configurations..." -ForegroundColor yellow
  Get-WmiObject -Class win32_networkadapterconfiguration -ComputerName $computers | select PSComputername, IPAddress, IPSubnet, DefaultIPGateway, DHCPServer, DNSHostname, DNSserversearchorder, MACAddress, description| Export-CSV "\\186.189.182.154\share" -Append -NoTypeInformation
  # Shares
  Write-Host "Retrieving shares information..." -ForegroundColor yellow
  Get-WmiObject -Class win32_share -ComputerName $computers |select PSComputername, Name, Path, Description | Export-CSV "\\186.189.182.154\share" -Append -NoTypeInformation
  # Disk information
  Write-Host "Retrieving disk information..." -ForegroundColor yellow
  Get-WmiObject -Class win32_logicaldisk -ComputerName $computers | select PSComputername, DeviceID, Description, ProviderName | Export-CSV "\\186.189.182.154\share" -Append -NoTypeInformation
  # System information
  Write-Host "Retrieving system information..." -ForegroundColor yellow
  Get-WmiObject -Class win32_computersystem -ComputerName $computers | select PSComputername, Domain, Model, Manufacturer, EnableDaylightSavingsTime, PartOfDomain, Roles, SystemType, NumberOfProcessors, TotalPhysicalMemory, Username | Export-CSV "\\186.189.182.154\share" -Append -NoTypeInformation
  # Patch information
  Write-Host "Retrieving installed patch information..." -ForegroundColor yellow
  Get-WmiObject -Class win32_quickfixengineering -ComputerName $computers | select PSComputername, HotFixID, Description, InstalledBy, InstalledOn | Export-CSV "\\186.189.182.154\share" -Append -NoTypeInformation
  # Installed Software
  Write-Host "Retrieving installed software information..." -ForegroundColor yellow
  Get-WmiObject -Class win32_product -ComputerName $computers | select PSComputername, Name, PackageCache, Vendor, Version, IdentifyingNumber | Export-CSV "\\186.189.182.154\share" -Append -NoTypeInformation
  Set-Location -Path "\\186.189.182.154\share"
  # Network connections
  Write-Host "Retrieving network connections..." -ForegroundColor Yellow 
  foreach($computer in $computers){
    Invoke-WmiMethod -Class Win32_Process -Name Create -Computername $computers -ArgumentList "cmd /c netstat -ano > '\\186.189.182.154\share'" >$null 2>&1
    Copy-Item "\\186.189.182.154\share" "\\186.189.182.154\share" -Force
    $conn = (Get-Content -Path "\\186.189.182.154\share")
    $conn2 = $conn | foreach {$computer + $_}
    $conn2 | select -skip 4 | Out-File ".\$computer'_'.txt" 
  }
  # Combining network connection files
  cd ..
  Get-Content "\\186.189.182.154\share" | Out-File "\\186.189.182.154\share"
  # Cleaning up
  Remove-Item -Path "\\186.189.182.154\share'_'.txt" -Force
  Remove-Item "\\186.189.182.154\share" -Force
  Merge-Csv -InputObject (ipcsv "\\186.189.182.154\share"),(ipcsv "\\186.189.182.154\share"), (ipcsv "\\186.189.182.154\share") -Identity 'PSComputerName' -AllowDuplicates | Sort-Object 'PSComputerName' | Export-Excel -Path "\\186.189.182.154\share" -Append -AutoSize -BoldTopRow
  $LogFile | Disable-LogFile
  {
    # Sending E-mail
  }
}