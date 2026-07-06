# Purpose: MyMSI — Reusable PowerShell function libraries.

$ErrorActionPreference = "Stop"

$VerbosePreference = "SilentlyContinue"

$DebugPreference = "Continue"


$OriginalMSI = "C:\Users\$env:USERNAME\Desktop\Chrome-64-140-x64.msi"
$OriginalMSI = "C:\Temp\Chrome-64-140-x64.msi"


$WorkingMSI = "$($ENV:TEMP)\$([System.IO.Path]::GetFileName($OriginalMSI))"
If ([System.IO.File]::Exists($WorkingMSI))
{
  [System.IO.File]::Delete($WorkingMSI)
}
[System.IO.File]::Copy($OriginalMSI, $WorkingMSI)

$WorkingMST = "$($ENV:TEMP)\$([System.IO.Path]::GetFileNameWithoutExtension($OriginalMSI)).mst"
If ([System.IO.File]::Exists($WorkingMST))
{
  [System.IO.File]::Delete($WorkingMST)
}

$ExportFile = "MyExport.txt"

#region ******** My Custom MSI Functions ********

#region function Open-MyWindowsInstaller
function Open-MyWindowsInstaller()
{
  <#
    .SYNOPSIS
      Create a Windows Installer COM Object
    .DESCRIPTION
      Create a Windows Installer COM Object
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Open-MyWindowsInstaller
    .EXAMPLE
      $MyWindowsInstaller = Open-MyWindowsInstaller -PassThru
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Switch]$Alt,
    [Switch]$PassThru
  )
  Write-Verbose -Message "Enter Function Open-MyWindowsInstaller"
  $Script:MyInstaller = [PSCustomObject]@{
    "Installer" = $Null;;
    "Version" = ""
    "Connect" = $False
  }
  Try
  {
    $Script:MyInstaller.Installer = New-Object -ComObject WindowsInstaller.Installer
    if ($Alt)
    {
      $Version = $Script:MyInstaller.Installer.Version()
    }
    else
    {
      $Version = $Script:MyInstaller.Installer.GetType().InvokeMember("Version", [System.Reflection.BindingFlags]::GetProperty, $Null, $Script:MyInstaller.Installer, $Null)
    }
    $Script:MyInstaller.Version = [System.Version]::Parse($Version)
    $Script:MyInstaller.Connect = $True
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  if ($PassThru)
  {
    $Script:MyInstaller
  }
  Write-Verbose -Message "Exit Function Open-MyWindowsInstaller"
}
#endregion

#region function Close-MyWindowsInstaller
function Close-MyWindowsInstaller()
{
  <#
    .SYNOPSIS
      Release a Windows Installer COM Object
    .DESCRIPTION
      Release a Windows Installer COM Object
    .PARAMETER Installer
    .PARAMETER PassThru
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Close-MyWindowsInstaller
    .EXAMPLE
      Close-MyWindowsInstaller -Installer $MyWindowsInstaller
    .EXAMPLE
      $MyWindowsInstaller = Close-MyWindowsInstaller -PassThru
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Installer = $Script:MyInstaller,
    [Switch]$PassThru
  )
  Write-Verbose -Message "Enter Function Close-MyWindowsInstaller"
  Try
  {
    [Void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($Installer.Installer)
    $Installer.Installer = $Null
    $Installer.Connect = $False
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  if ($PassThru)
  {
    $Installer
  }
  [System.GC]::Collect()
  [System.GC]::WaitForPendingFinalizers()
  Write-Verbose -Message "Exit Function Close-MyWindowsInstaller"
}
#endregion


#region function Get-MyInstallerProduct
function Get-MyInstallerProduct()
{
  <#
    .SYNOPSIS
      Gets Installed Products
    .DESCRIPTION
      Gets Installed Products
    .PARAMETER Installer
    .PARAMETER ProductID
    .PARAMETER AllUsers
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Get-MyInstallerProduct
    .EXAMPLE
      Get-MyInstallerProduct -Installer $MyInstaller
    .EXAMPLE
      Get-MyInstallerProduct -Installer $MyInstaller -ProductID "00000000-0000-0000-0000-000000000000"
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Installer = $Script:MyInstaller,
    [String]$ProductID,
    [Switch]$AllUsers,
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Get-MyInstallerProduct"
  Try
  {
    if ($AllUsers)
    {
      $SID = "S-1-1-0"
    }
    else
    {
      $SID = ""
    }
    if ($Alt)
    {
      $Products = $Installer.Installer.ProductsEx("$ProductID", $SID, 7)
      ForEach ($Product in $Products)
      {
        Try
        {
          [PSCustomObject]@{
            "ProductCode" = $Product.ProductCode();
            "Language" = $Product.InstallProperty("Language");
            "ProductName" = $Product.InstallProperty("ProductName");
            "PackageCode" = $Product.InstallProperty("PackageCode");
            "Transforms" = $Product.InstallProperty("Transforms");
            "AssignmentType" = $Product.InstallProperty("AssignmentType");
            "PackageName" = $Product.InstallProperty("PackageName");
            "InstalledProductName" = $Product.InstallProperty("InstalledProductName");
            "VersionString" = $Product.InstallProperty("VersionString");
            "RegCompany" = $Product.InstallProperty("RegCompany");
            "RegOwner" = $Product.InstallProperty("RegOwner");
            "ProductID" = $Product.InstallProperty("ProductID");
            "ProductIcon" = $Product.InstallProperty("ProductIcon");
            "InstallLocation" = $Product.InstallProperty("InstallLocation");
            "InstallSource" = $Product.InstallProperty("InstallSource");
            "InstallDate" = $Product.InstallProperty("InstallDate");
            "Publisher" = $Product.InstallProperty("Publisher");
            "LocalPackage" = $Product.InstallProperty("LocalPackage");
            "HelpLink" = $Product.InstallProperty("HelpLink");
            "HelpTelephone" = $Product.InstallProperty("HelpTelephone");
            "URLInfoAbout" = $Product.InstallProperty("URLInfoAbout");
            "URLUpdateInfo" = $Product.InstallProperty("URLUpdateInfo")
          }
        }
        Catch
        {
          #Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
          #Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
          #Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
        }
      }
    }
    else
    {
      $Products = $Installer.Installer.GetType().InvokeMember("ProductsEx", [System.Reflection.BindingFlags]::GetProperty, $Null, $Installer.Installer, @("$ProductID", $SID, 7))
      ForEach ($Product in $Products)
      {
        Try
        {
          [PSCustomObject]@{
            "ProductCode" = $Product.GetType().InvokeMember("ProductCode", [System.Reflection.BindingFlags]::GetProperty, $Null, $Product, $Null);
            "Language" = $Product.GetType().InvokeMember("InstallProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Product, @("Language"));
            "ProductName" = $Product.GetType().InvokeMember("InstallProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Product, @("ProductName"));
            "PackageCode" = $Product.GetType().InvokeMember("InstallProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Product, @("PackageCode"));
            "Transforms" = $Product.GetType().InvokeMember("InstallProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Product, @("Transforms"));
            "AssignmentType" = $Product.GetType().InvokeMember("InstallProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Product, @("AssignmentType"));
            "PackageName" = $Product.GetType().InvokeMember("InstallProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Product, @("PackageName"));
            "InstalledProductName" = $Product.GetType().InvokeMember("InstallProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Product, @("InstalledProductName"));
            "VersionString" = $Product.GetType().InvokeMember("InstallProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Product, @("VersionString"));
            "RegCompany" = $Product.GetType().InvokeMember("InstallProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Product, @("RegCompany"));
            "RegOwner" = $Product.GetType().InvokeMember("InstallProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Product, @("RegOwner"));
            "ProductID" = $Product.GetType().InvokeMember("InstallProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Product, @("ProductID"));
            "ProductIcon" = $Product.GetType().InvokeMember("InstallProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Product, @("ProductIcon"));
            "InstallLocation" = $Product.GetType().InvokeMember("InstallProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Product, @("InstallLocation"));
            "InstallSource" = $Product.GetType().InvokeMember("InstallProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Product, @("InstallSource"));
            "InstallDate" = $Product.GetType().InvokeMember("InstallProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Product, @("InstallDate"));
            "Publisher" = $Product.GetType().InvokeMember("InstallProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Product, @("Publisher"));
            "LocalPackage" = $Product.GetType().InvokeMember("InstallProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Product, @("LocalPackage"));
            "HelpLink" = $Product.GetType().InvokeMember("InstallProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Product, @("HelpLink"));
            "HelpTelephone" = $Product.GetType().InvokeMember("InstallProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Product, @("HelpTelephone"));
            "URLInfoAbout" = $Product.GetType().InvokeMember("InstallProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Product, @("URLInfoAbout"));
            "URLUpdateInfo" = $Product.GetType().InvokeMember("InstallProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Product, @("URLUpdateInfo"))
          }
        }
        Catch
        {
          #Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
          #Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
          #Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
        }
      }
    }
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  $Products = $Null
  $Product = $Null
  Write-Verbose -Message "Exit Function Get-MyInstallerProduct"
}
#endregion

#region function Get-MyProductGUID
function Get-MyProductGUID()
{
  <#
    .SYNOPSIS
      Gets Installed ProductIDs for Installed Products
    .DESCRIPTION
      Gets Installed ProductIDs for Installed Products
    .PARAMETER Installer
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Get-MyProductGUID
    .EXAMPLE
      Get-MyProductGUID -Installer $MyInstaller
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Installer = $Script:MyInstaller,
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Get-MyProductGUID"
  Try
  {
    if ($Alt)
    {
      $Installer.Installer.Products()
    }
    else
    {
      $Installer.Installer.GetType().InvokeMember("Products", [System.Reflection.BindingFlags]::GetProperty, $Null, $Installer.Installer, $Null)
    }
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  Write-Verbose -Message "Exit Function Get-MyProductGUID"
}
#endregion

#region function Get-MyProductPatch
function Get-MyProductPatch()
{
  <#
    .SYNOPSIS
      Get Installed patches for an Installed Product
    .DESCRIPTION
      Get Installed patches for an Installed Product
    .PARAMETER Installer
    .PARAMETER ProductID
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Get-MyProductPatch -ProductID "00000000-0000-0000-0000-000000000000"
    .EXAMPLE
      Get-MyProductPatch -Installer $MyInstaller -ProductID "00000000-0000-0000-0000-000000000000"
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Installer = $Script:MyInstaller,
    [parameter(Mandatory = $True)]
    [String]$ProductID,
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Get-MyProductPatch"
  Try
  {
    if ($Alt)
    {
      $Patchs = $Installer.Installer.PatchesEx("$ProductID", "S-1-1-0", 7, 1)
      ForEach ($Patch in $Patchs)
      {
        Try
        {
          [PSCustomObject]@{
            "DisplayName" = $Patch.PatchProperty("DisplayName");
            "InstallDate" = $Patch.PatchProperty("InstallDate");
            "LocalPackage" = $Patch.PatchProperty("LocalPackage");
            "Uninstallable" = $Patch.PatchProperty("Uninstallable");
            "State" = $Patch.PatchProperty("State");
            "MoreInfoURL" = $Patch.PatchProperty("MoreInfoURL");
            "Transforms" = $Patch.PatchProperty("Transforms")
          }
        }
        Catch
        {
        }
      }
    }
    else
    {
      $Patchs = $Installer.Installer.GetType().InvokeMember("PatchesEx", "GetProperty", $Null, $Installer.Installer, @("$ProductID", "S-1-1-0", 7, 1))
      ForEach ($Patch in $Patchs)
      {
        Try
        {
          [PSCustomObject]@{
            "DisplayName" = $Patch.GetType().InvokeMember("PatchProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Patch, @("DisplayName"));
            "InstallDate" = $Patch.GetType().InvokeMember("PatchProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Patch, @("InstallDate"));
            "LocalPackage" = $Patch.GetType().InvokeMember("PatchProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Patch, @("LocalPackage"));
            "Uninstallable" = $Patch.GetType().InvokeMember("PatchProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Patch, @("Uninstallable"));
            "State" = $Patch.GetType().InvokeMember("PatchProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Patch, @("State"));
            "MoreInfoURL" = $Patch.GetType().InvokeMember("PatchProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Patch, @("MoreInfoURL"));
            "Transforms" = $Patch.GetType().InvokeMember("PatchProperty", [System.Reflection.BindingFlags]::GetProperty, $Null, $Patch, @("Transforms"))
          }
        }
        Catch
        {
        }
      }
    }
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  $Patchs = $null
  $Patch = $Null
  Write-Verbose -Message "Exit Function Get-MyProductPatch"
}
#endregion

#region function Get-MyInstallerComponent
function Get-MyInstallerComponent()
{
  <#
    .SYNOPSIS
      Get String List of Installed Components
    .DESCRIPTION
      Get String List of Installed Components
    .PARAMETER Installer
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Get-MyInstallerComponent
    .EXAMPLE
      Get-MyInstallerComponent -Installer $MyInstaller
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Installer = $Script:MyInstaller,
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Get-MyInstallerComponent"
  Try
  {
    if ($Alt)
    {
      $Installer.Installer.Components()
    }
    else
    {
      $Installer.Installer.GetType().InvokeMember("Components", [System.Reflection.BindingFlags]::GetProperty, $Null, $Installer.Installer, $Null)
    }
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  Write-Verbose -Message "Exit Function Get-MyInstallerComponent"
}
#endregion

#region function Get-MyInstallerErrorRecord
function Get-MyInstallerErrorRecord()
{
  <#
    .SYNOPSIS
      Get String List of ErrorRecord
    .DESCRIPTION
      Get String List of ErrorRecord
    .PARAMETER Installer
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Get-MyInstallerErrorRecord
    .EXAMPLE
      Get-MyInstallerErrorRecord -Installer $MyInstaller
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Installer = $Script:MyInstaller,
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Get-MyInstallerErrorRecord"
  Try
  {
    if ($Alt)
    {
      $Record = $Installer.Installer.LastErrorRecord()
      If ([String]::IsNullOrEmpty($Record))
      {
        [PSCustomObject]@{
          "Error" = 0;
          "MSI" = "";
          "ExitCode" = 0
        }
      }
      else
      {
        [PSCustomObject]@{
          "Error" = $Record.IntegerData(1);
          "MSI" = $Record.StringData(2);
          "ExitCode" = $Record.IntegerData(3)
        }
      }
    }
    else
    {
      $Record = $Installer.Installer.GetType().InvokeMember("LastErrorRecord", [System.Reflection.BindingFlags]::GetProperty, $Null, $Installer.Installer, $Null)
      If ([String]::IsNullOrEmpty($Record))
      {
        [PSCustomObject]@{
          "Error" = 0;
          "MSI" = "";
          "ExitCode" = 0
        }
      }
      else
      {
        [PSCustomObject]@{
          "Error" = $Record.GetType().InvokeMember("IntegerData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @(1));
          "MSI" = $Record.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @(2));
          "ExitCode" = $Record.GetType().InvokeMember("IntegerData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @(3))
        }
      }
    }
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  $Record = $Null
  Write-Verbose -Message "Exit Function Get-MyInstallerErrorRecord"
}
#endregion



#region function Open-MyMSIProduct
function Open-MyMSIProduct()
{
  <#
    .SYNOPSIS
      Open an Installed Product
    .DESCRIPTION
      Open an Installed Product
    .PARAMETER Installer
    .PARAMETER GUID
    .PARAMETER Alt
    .PARAMETER PassThru
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Open-MyMSIProduct -GUID "00000000-0000-0000-0000-000000000000"
    .EXAMPLE
      $MyMSIProduct = Open-MyMSIProduct -GUID "00000000-0000-0000-0000-000000000000" -PassThru
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Installer = $Script:MyInstaller,
    [parameter(Mandatory = $True)]
    [String]$GUID,
    [Switch]$Alt,
    [Switch]$PassThru
  )
  Write-Verbose -Message "Enter Function Open-MyMSIProduct"
  $Script:MyMSIProduct = [PSCustomObject]@{
    "Product" = $Null;
    "Connect" = $False
  }
  Try
  {
    if ($Alt)
    {
      $Script:MyMSIProduct.Product = $Installer.Installer.OpenProduct($GUID)
    }
    else
    {
      $Script:MyMSIProduct.Product = $Installer.Installer.GetType().InvokeMember("OpenProduct", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Installer.Installer, @($GUID))
    }
    $Script:MyMSIProduct.Connect = $True
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  if ($PassThru)
  {
    $Script:MyMSIProduct
  }
  Write-Verbose -Message "Exit Function Open-MyMSIProduct"
}
#endregion

#region function Close-MyMSIProduct
function Close-MyMSIProduct()
{
  <#
    .SYNOPSIS
      Close an Open Product
    .DESCRIPTION
      Close an Open Product
    .PARAMETER Product
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Close-MyMSIProduct -Product $MyMSIProduct
    .EXAMPLE
      $MyMSIProduct = Close-MyMSIProduct -Product $MyMSIProduct -PassThru
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Product = $Script:MyMSIProduct
  )
  Write-Verbose -Message "Enter Function Close-MyMSIProduct"
  Try
  {
    [Void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($Product.Product)
    $Product.Product = $Null
    $Product.Connect = $False
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  if ($PassThru)
  {
    $Product
  }
  [System.GC]::Collect()
  [System.GC]::WaitForPendingFinalizers()
  Write-Verbose -Message "Exit Function Close-MyMSIProduct"
}
#endregion



#region function Open-MyMSIDatabase
function Open-MyMSIDatabase()
{
  <#
    .SYNOPSIS
      Open a MSI or MSP Database
    .DESCRIPTION
      Open a MSI or MSP Database
    .PARAMETER Installer
    .PARAMETER Path
    .PARAMETER Mode
    .PARAMETER Patch
    .PARAMETER Alt
    .PARAMETER PassThru
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Open-MyMSIDatabase -Path "C:\MyMSIFile.msi"
    .EXAMPLE
      Open-MyMSIDatabase -Path "C:\MyMSIFile.msi" -Mode "ReadWrite"
    .EXAMPLE
      $MyMSIDatabase = Open-MyMSIDatabase -Path "C:\MyMSPFile.msp" -Patch -PassThru
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Installer = $Script:MyInstaller,
    [parameter(Mandatory = $True)]
    [ValidateScript({ [IO.File]::Exists($PSItem) })]
    [String]$Path,
    [ValidateSet("ReadOnly", "ReadWrite", "Create", "List")]
    [String]$Mode = "ReadOnly",
    [Switch]$Patch,
    [Switch]$Alt,
    [Switch]$PassThru
  )
  Write-Verbose -Message "Enter Function Open-MyMSIDatabase"
  $Script:MyMSIDatabase = [PSCustomObject]@{
    "Database" = $Null;
    "Connect" = $False
  }
  Switch ($Mode)
  {
    "ReadOnly"
    {
      $OpenMode = 0
      Break
    }
    "ReadWrite"
    {
      $OpenMode = 1
      Break
    }
    "Create"
    {
      $OpenMode = 3
      Break
    }
    "List"
    {
      $OpenMode = 5
      Break
    }
  }
  if ($Patch)
  {
    $OpenMode += 32
  }
  Try
  {
    if ($Alt)
    {
      $Script:MyMSIDatabase.Database = $Installer.Installer.OpenDatabase($Path, $OpenMode)
    }
    else
    {
      $Script:MyMSIDatabase.Database = $Installer.Installer.GetType().InvokeMember("OpenDatabase", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Installer.Installer, @($Path, $OpenMode))
    }
    $Script:MyMSIDatabase.Connect = $True
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  if ($PassThru)
  {
    $Script:MyMSIDatabase
  }
  $OpenMode = $Null
  Write-Verbose -Message "Exit Function Open-MyMSIDatabase"
}
#endregion

#region function Save-MyMSIDatabase
function Save-MyMSIDatabase()
{
  <#
    .SYNOPSIS
      Save Changes to an Open MSI or MSP Database
    .DESCRIPTION
      Save Changes to an Open MSI or MSP Database
    .PARAMETER Database
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Save-MyMSIDatabase -Database $MyMSIDatabase
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Database = $Script:MyMSIDatabase,
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Save-MyMSIDatabase"
  $Commit = $False
  Try
  {
    if ($Alt)
    {
      $Database.Database.Commit()
    }
    else
    {
      $Database.Database.GetType().InvokeMember("Commit", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Database.Database, $Null)
    }
    $Commit = $True
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  [PSCustomObject]@{"Commit" = $Commit}
  Write-Verbose -Message "Exit Function Save-MyMSIDatabase"
}
#endregion

#region function Close-MyMSIDatabase
function Close-MyMSIDatabase()
{
  <#
    .SYNOPSIS
      Close an Open MSI or MSP Database
    .DESCRIPTION
      Close an Open MSI or MSP File Database
    .PARAMETER Database
    .PARAMETER PassThru
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Close-MyMSIDatabase -Database $MyMSIDatabase
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Database = $Script:MyMSIDatabase,
    [Switch]$PassThru
  )
  Write-Verbose -Message "Enter Function Close-MyMSIDatabase"
  Try
  {
    [Void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($Database.Database)
    $Database.Database = $Null
    $Database.Connect = $False
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  if ($PassThru)
  {
    $Database
  }
  [System.GC]::Collect()
  [System.GC]::WaitForPendingFinalizers()
  Write-Verbose -Message "Exit Function Close-MyMSIDatabase"
}
#endregion


#region function Get-MyMSIScript
function Get-MyMSIScript()
{
  <#
    .SYNOPSIS
      Get Some Script from an Open MSI Database
    .DESCRIPTION
      Get Some Script from an Open MSI Database
    .PARAMETER Database
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Get-MyMSIScript -Database $MyMSIDatabase
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Database = $Script:MyMSIDatabase,
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Get-MyMSIScript"
  Try
  {
    if ($Alt)
    {
      $View = $Database.Database.OpenView("")
      [Void]$View.Execute()
      While (($Record = $View.Fetch()))
      {
        $FieldCount = $Record.FieldCount()
        $Template = $Record.StringData(0)
        $Index = $Template.LastIndexof("[") + 1
        if ($Index -gt 1)
        {
          $Field = [Int]($Template.SubString($Index, ($Template.LastIndexof("]") - $Index)))
          While ($Field -lt $FieldCount)
          {
            $Field += 1
            $Template = $Template + ",[$Field]"
          }
          $Record.StringData(0) = $Template
        }
        $Record.FormatText()
      }
      [Void]$View.Close()
    }
    else
    {
      $View = $Database.Database.GetType().InvokeMember("OpenView", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Database.Database, @(""))
      [Void]$View.GetType().InvokeMember("Execute", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
      While (($Record = $View.GetType().InvokeMember("Fetch", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)))
      {
        $FieldCount = $Record.GetType().InvokeMember("FieldCount", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, $Null)
        $Template = $Record.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @(0))
        $Index = $Template.LastIndexof("[") + 1
        if ($Index -gt 1)
        {
          $Field = [Int]($Template.SubString($Index, ($Template.LastIndexof("]") - $Index)))
          While ($Field -lt $FieldCount)
          {
            $Field += 1
            $Template = $Template + ",[$Field]"
          }
          [Void]$Record.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::SetProperty, $Null, $Record, @(0, $Template))
        }
        $Record.GetType().InvokeMember("FormatText", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Record, $Null)
      }
      [Void]$View.GetType().InvokeMember("Close", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
    }
    [Void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  $View = $Null
  $Record = $Null
  $Template = $Null
  $FieldCount = $Null
  $Field = $Null
  $Index = $Null
  [System.GC]::Collect()
  [System.GC]::WaitForPendingFinalizers()
  Write-Verbose -Message "Exit Function Get-MyMSIScript"
}
#endregion

#region function Confirm-MyMSITablePersistent
function Confirm-MyMSITablePersistent()
{
  <#
    .SYNOPSIS
      Confirm if Table Exists in Open MSI Database
    .DESCRIPTION
      Confirm if Table Exists in Open MSI Database
    .PARAMETER Database
    .PARAMETER Table
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Confirm-MyMSITablePersistent -Table "Property"
    .EXAMPLE
      Confirm-MyMSITablePersistent -Database $MyMSIDatabase -Table "Property"
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Database = $Script:MyMSIDatabase,
    [parameter(Mandatory = $True)]
    [String]$Table,
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Confirm-MyMSITablePersistent"
  Try
  {
    if ($Alt)
    {
      $Status = $Database.Database.TablePersistent($Table)
    }
    else
    {
      $Status = $Database.Database.GetType().InvokeMember("TablePersistent", [System.Reflection.BindingFlags]::GetProperty, $Null, $Database.Database, @($Table))
    }
  }
  Catch
  {
    $Status = 3
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  Switch ($Status)
  {
    1
    {
      $Message = "Persistent"
      Break
    }
    0
    {
      $Message = "Temporary"
      Break
    }
    2
    {
      $Message = "Missing"
      Break
    }
    Default
    {
      $Message = "Invalid"
      Break
    }
  }
  [PSCustomObject]@{
    "Status" = $Status;
    "Message" = $Message
  }
  Write-Verbose -Message "Exit Function Confirm-MyMSITablePersistent"
}
#endregion

#region function Get-MyMSITableColumn
function Get-MyMSITableColumn()
{
  <#
    .SYNOPSIS
      Get the Column Names of a MSI Database Table
    .DESCRIPTION
      Get the Column Names of a MSI Database Table
    .PARAMETER Database
    .PARAMETER Table
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Get-MyMSITableColumn -Table "Property"
    .EXAMPLE
      Get-MyMSITableColumn -Database $MyMSIDatabase -Table "Property"
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Database = $Script:MyMSIDatabase,
    [String]$Table,
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Get-MyMSITableColumn"
  if ($PSBoundParameters.ContainsKey("Table"))
  {
    $Query = "Select * from ``_Columns`` Where ``Table`` = '$Table' Order by ``Number``"
  }
  else
  {
    $Query = "Select * from ``_Columns`` Order by ``Table``, ``Number``"
  }
  Try
  {
    if ($Alt)
    {
      $View = $Database.Database.OpenView($Query)
      [Void]$View.Execute()
      While (($Record = $View.Fetch()))
      {
        [PSCustomObject]@{
          "Table" = $Record.StringData(1);
          "Number" = $Record.StringData(2);
          "Name" = $Record.StringData(3)
        }
      }
      [Void]$View.Close()
    }
    else
    {
      $View = $Database.Database.GetType().InvokeMember("OpenView", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Database.Database, @($Query))
      [Void]$View.GetType().InvokeMember("Execute", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
      While (($Record = $View.GetType().InvokeMember("Fetch", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)))
      {
        [PSCustomObject]@{
          "Table" = $Record.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @(1));
          "Number" = $Record.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @(2));
          "Name" = $Record.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @(3))
        }
      }
      [Void]$View.GetType().InvokeMember("Close", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
    }
    [Void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  $View = $Null
  $Record = $Null
  $Query = $Null
  [System.GC]::Collect()
  [System.GC]::WaitForPendingFinalizers()
  Write-Verbose -Message "Exit Function Get-MyMSITableColumn"
}
#endregion

#region function Get-MyMSITableColumnType
function Get-MyMSITableColumnType()
{
  <#
    .SYNOPSIS
      Get the Table Record Properties from an Open MSI Database
    .DESCRIPTION
      Get the Table Record Properties from an Open MSI Database
    .PARAMETER Database
    .PARAMETER Table
    .PARAMETER Propery
    .PARAMETER Value
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Get-MyMSITableColumnType -Table "Property"
    .EXAMPLE
      Get-MyMSITableColumnType -Table "Property" -Propery "Property" -Value "Value"
    .EXAMPLE
      Get-MyMSITableColumnType -Database $MyMSIDatabase -Table "Property"
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Database = $Script:MyMSIDatabase,
    [parameter(Mandatory = $True)]
    [String]$Table,
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Get-MyMSITableColumnType"
  $Query = "Select * from ``$Table``"
  Try
  {
    if ($Alt)
    {
      $View = $Database.Database.OpenView($Query)
      $ColumnNames = $View.ColumnInfo(0)
      $FieldCount = $ColumnNames.FieldCount()
      $ColumnTypes = $View.ColumnInfo(1)
      For ($Index = 1; $Index -le $FieldCount; $Index++)
      {
        $ColumnType = $ColumnTypes.StringData($Index)
        $Size = [int]($ColumnType.SubString(1))
        $Temporary = $False
        $Localizable = $False
        Switch ($ColumnType.SubString(0, 1))
        {
          "S"
          {
            if ($Size -eq 0)
            {
              $Type = "LONGCHAR"
            }
            else
            {
              $Type = "CHAR"
            }
            Break
          }
          "L"
          {
            if ($Size -eq 0)
            {
              $Type = "LONGCHAR"
            }
            else
            {
              $Type = "CHAR"
            }
            $Localizable = $True
            Break
          }
          "G"
          {
            if ($Size -eq 0)
            {
              $Type = "LONGCHAR"
            }
            else
            {
              $Type = "CHAR"
            }
            $Temporary = $True
            Break
          }
          "I"
          {
            if ($Size -eq 2)
            {
              $Type = "SHORT"
            }
            else
            {
              $Type = "LONG"
            }
            Break
          }
          "J"
          {
            if ($Size -eq 2)
            {
              $Type = "SHORT"
            }
            else
            {
              $Type = "LONG"
            }
            $Temporary = $True
            Break
          }
          "V"
          {
            $Type = "BINARY"
            Break
          }
          "O"
          {
            $Type = "BINARY"
            $Temporary = $True
            Break
          }
        }
        [PSCustomObject]@{
          "Name" = $ColumnNames.StringData($Index);
          "ColumnType" = $ColumnType;
          "Order" = $Index;
          "Type" = $Type;
          "Size" = $Size;
          "Nullable" = ($ColumnType -ceq $ColumnType.ToUpper());
          "Temporary" = $Temporary;
          "Localizable" = $Localizable
        }
      }
      [Void]$View.Close()
    }
    else
    {
      $View = $Database.Database.GetType().InvokeMember("OpenView", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Database.Database, @($Query))
      $ColumnNames = $View.GetType().InvokeMember("ColumnInfo", [System.Reflection.BindingFlags]::GetProperty, $Null, $View, @(0))
      $FieldCount = $ColumnNames.GetType().InvokeMember("FieldCount", [System.Reflection.BindingFlags]::GetProperty, $Null, $ColumnNames, $Null)
      $ColumnTypes = $View.GetType().InvokeMember("ColumnInfo", [System.Reflection.BindingFlags]::GetProperty, $Null, $View, @(1))
      For ($Index = 1; $Index -le $FieldCount; $Index++)
      {
        $ColumnType = $ColumnTypes.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::GetProperty, $Null, $ColumnTypes, @($Index))
        $Size = [int]($ColumnType.SubString(1))
        $Temporary = $False
        $Localizable = $False
        Switch ($ColumnType.SubString(0, 1))
        {
          "S"
          {
            if ($Size -eq 0)
            {
              $Type = "LONGCHAR"
            }
            else
            {
              $Type = "CHAR"
            }
            Break
          }
          "L"
          {
            if ($Size -eq 0)
            {
              $Type = "LONGCHAR"
            }
            else
            {
              $Type = "CHAR"
            }
            $Localizable = $True
            Break
          }
          "G"
          {
            if ($Size -eq 0)
            {
              $Type = "LONGCHAR"
            }
            else
            {
              $Type = "CHAR"
            }
            $Temporary = $True
            Break
          }
          "I"
          {
            if ($Size -eq 2)
            {
              $Type = "SHORT"
            }
            else
            {
              $Type = "LONG"
            }
            Break
          }
          "J"
          {
            if ($Size -eq 2)
            {
              $Type = "SHORT"
            }
            else
            {
              $Type = "LONG"
            }
            $Temporary = $True
            Break
          }
          "V"
          {
            $Type = "BINARY"
            Break
          }
          "O"
          {
            $Type = "BINARY"
            $Temporary = $True
            Break
          }
        }
        [PSCustomObject]@{
          "Name" = $ColumnNames.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::GetProperty, $Null, $ColumnNames, @($Index));
          "ColumnType" = $ColumnType;
          "Order" = $Index;
          "Type" = $Type;
          "Size" = $Size;
          "Nullable" = ($ColumnType -ceq $ColumnType.ToUpper());
          "Temporary" = $Temporary;
          "Localizable" = $Localizable
        }
      }
      [Void]$View.GetType().InvokeMember("Close", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
    }
    [Void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  $View = $Null
  $Query = $Null
  $ColumnNames = $Null
  $ColumnTypes = $Null
  $FieldCount = $Null
  $Temporary = $Null
  $Localizable = $Null
  $ColumnType = $Null
  $Type = $Null
  $Size = $Null
  [System.GC]::Collect()
  [System.GC]::WaitForPendingFinalizers()
  Write-Verbose -Message "Exit Function Get-MyMSITableColumnType"
}
#endregion

#region function Get-MyMSIValidation
function Get-MyMSIValidation()
{
  <#
    .SYNOPSIS
      Get the Validation Information of an Open MSI Database Table
    .DESCRIPTION
      Get the Validation Information of an Open MSI Database Table
    .PARAMETER Database
    .PARAMETER Table
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Get-MyMSIValidation -Table "Property"
    .EXAMPLE
      Get-MyMSIValidation -Database $MyMSIDatabase -Table "Property"
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Database = $Script:MyMSIDatabase,
    [parameter(Mandatory = $True)]
    [String]$Table,
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Get-MyMSIValidation"
  $Query = "Select ``_Validation``.``Table``, ``_Validation``.``Column``, ``_Validation``.``Nullable``, ``_Validation``.``MinValue``, ``_Validation``.``MaxValue``, ``_Validation``.``KeyTable``, ``_Validation``.``KeyColumn``, ``_Validation``.``Category``, ``_Validation``.``Set``, ``_Validation``.``Description``, ``_Columns``.``Number`` From ``_Validation``, ``_Columns`` Where ``_Validation``.``Table`` = ``_Columns``.``Table`` and ``_Validation``.``Column`` = ``_Columns``.``Name`` and ``_Validation``.``Table`` = '$Table' Order By ``_Columns``.``Number``"
  Try
  {
    if ($Alt)
    {
      $View = $Database.Database.OpenView($Query)
      [Void]$View.Execute()
      While (($Record = $View.Fetch()))
      {
        [PSCustomObject]@{
          "Table" = $Record.StringData(1);
          "Column" = $Record.StringData(2);
          "Nullable" = $Record.StringData(3);
          "MinValue" = $Record.IntegerData(4);
          "MaxValue" = $Record.IntegerData(5);
          "KeyTable" = $Record.StringData(6);
          "KeyColumn" = $Record.IntegerData(7);
          "Category" = $Record.StringData(8);
          "Set" = $Record.StringData(9);
          "Description" = $Record.StringData(10);
          "Number" = $Record.IntegerData(11);
        }
      }
      [Void]$View.Close()
    }
    else
    {
      $View = $Database.Database.GetType().InvokeMember("OpenView", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Database.Database, @($Query))
      [Void]$View.GetType().InvokeMember("Execute", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
      While (($Record = $View.GetType().InvokeMember("Fetch", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)))
      {
        [PSCustomObject]@{
          "Table" = $Record.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @(1));
          "Column" = $Record.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @(2));
          "Nullable" = $Record.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @(3));
          "MinValue" = $Record.GetType().InvokeMember("IntegerData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @(4));
          "MaxValue" = $Record.GetType().InvokeMember("IntegerData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @(5));
          "KeyTable" = $Record.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @(6));
          "KeyColumn" = $Record.GetType().InvokeMember("IntegerData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @(7));
          "Category" = $Record.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @(8))
          "Set" = $Record.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @(9));
          "Description" = $Record.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @(10));
          "Number" = $Record.GetType().InvokeMember("IntegerData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @(11));
        }
      }
      [Void]$View.GetType().InvokeMember("Close", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
    }
    [Void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  $View = $Null
  $Record = $Null
  $Query = $Null
  [System.GC]::Collect()
  [System.GC]::WaitForPendingFinalizers()
  Write-Verbose -Message "Exit Function Get-MyMSIValidation"
}
#endregion

#region function Get-MyMSITable
function Get-MyMSITable()
{
  <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER Database
    .PARAMETER Table
    .PARAMETER Propery
    .PARAMETER Value
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Get-MyMSITable -Table "Property"
    .EXAMPLE
      Get-MyMSITable -Table "Property" -Propery "Property" -Value "Value"
    .EXAMPLE
      Get-MyMSITable -Database $MyMSIDatabase -Table "Property"
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding(DefaultParameterSetName = "Property")]
  param (
    [Object]$Database = $Script:MyMSIDatabase,
    [parameter(Mandatory = $True, ParameterSetName = "Property")]
    [String]$Table,
    [parameter(Mandatory = $False, ParameterSetName = "Property")]
    [String]$Property,
    [parameter(Mandatory = $False, ParameterSetName = "Property")]
    [String]$Value,
    [parameter(Mandatory = $True, ParameterSetName = "List")]
    [Switch]$List,
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Get-MyMSITable"
  if ($PSCmdlet.ParameterSetName -eq "List")
  {
    $Query = "Select ``Name`` from ``_Tables`` Order By ``Name``"
  }
  else
  {
    if ($PSBoundParameters.ContainsKey("Property"))
    {
      $Query = "Select * from ``$Table`` Where ``$Property`` = '$Value'"
    }
    else
    {
      $Query = "Select * from ``$Table``"
    }
  }
  Try
  {
    if ($Alt)
    {
      $View = $Database.Database.OpenView($Query)
      $ColumnNames = $View.ColumnInfo(0)
      $FieldCount = $ColumnNames.FieldCount()
      $ColumnTypes = $View.ColumnInfo(1)
      $Columns = @{}
      For ($Index = 1; $Index -le $FieldCount; $Index++)
      {
        $Columns.Add($Index, @{
            "Name" = $ColumnNames.StringData($Index);
            "Type" =  $ColumnTypes.StringData($Index)
          })
      }
     [Void]$View.Execute()
      While (($Record = $View.Fetch()))
      {
        $NewObject = @{}
        For ($Index = 1; $Index -le $FieldCount; $Index++)
        {
          if ($Record.IsNull($Index))
          {
            $NewObject.Add($($Columns[$Index].Name), $Null)
          }
          else
          {
            Switch ($Columns[$Index].Type.SubString(0, 1))
            {
              "S"
              {
                $NewObject.Add($($Columns[$Index].Name), $($Record.StringData($Index)))
                Break
              }
              "L"
              {
                $NewObject.Add($($Columns[$Index].Name), $($Record.StringData($Index)))
                Break
              }
              "G"
              {
                $NewObject.Add($($Columns[$Index].Name), $($Record.StringData($Index)))
                Break
              }
              "I"
              {
                $NewObject.Add($($Columns[$Index].Name), $($Record.IntegerData($Index)))
                Break
              }
              "j"
              {
                $NewObject.Add($($Columns[$Index].Name), $($Record.IntegerData($Index)))
                Break
              }
              "V"
              {
                $NewObject.Add($($Columns[$Index].Name), $Record.DataSize($Index))
                Break
              }
              "O"
              {
                $NewObject.Add($($Columns[$Index].Name), $Record.DataSize($Index))
                Break
              }
              Default
              {
                $NewObject.Add($($Columns[$Index].Name), $Null)
                Break
              }
            }
          }
        }
        [PSCustomObject]$NewObject
      }
      [Void]$View.Close()
    }
    else
    {
      $View = $Database.Database.GetType().InvokeMember("OpenView", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Database.Database, @($Query))
      $ColumnNames = $View.GetType().InvokeMember("ColumnInfo", [System.Reflection.BindingFlags]::GetProperty, $Null, $View, @(0))
      $FieldCount = $ColumnNames.GetType().InvokeMember("FieldCount", [System.Reflection.BindingFlags]::GetProperty, $Null, $ColumnNames, $Null)
      $ColumnTypes = $View.GetType().InvokeMember("ColumnInfo", [System.Reflection.BindingFlags]::GetProperty, $Null, $View, @(1))
      $Columns = @{}
      For ($Index = 1; $Index -le $FieldCount; $Index++)
      {
        $Columns.Add($Index, @{
            "Name" = $ColumnNames.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::GetProperty, $Null, $ColumnNames, @($Index));
            "Type" =  $ColumnTypes.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::GetProperty, $Null, $ColumnTypes, @($Index))
          })
      }
      [Void]$View.GetType().InvokeMember("Execute", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
      While (($Record = $View.GetType().InvokeMember("Fetch", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)))
      {
        $NewObject = @{}
        For ($Index = 1; $Index -le $FieldCount; $Index++)
        {
          if ($Record.GetType().InvokeMember("IsNull", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @($Index)))
          {
            $NewObject.Add($($Columns[$Index].Name), $Null)
          }
          else
          {
            Switch ($Columns[$Index].Type.SubString(0, 1))
            {
              "S"
              {
                $NewObject.Add($($Columns[$Index].Name), $($Record.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @($Index))))
                Break
              }
              "L"
              {
                $NewObject.Add($($Columns[$Index].Name), $($Record.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @($Index))))
                Break
              }
              "G"
              {
                $NewObject.Add($($Columns[$Index].Name), $($Record.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @($Index))))
                Break
              }
              "I"
              {
                $NewObject.Add($($Columns[$Index].Name), $($Record.GetType().InvokeMember("IntegerData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @($Index))))
                Break
              }
              "J"
              {
                $NewObject.Add($($Columns[$Index].Name), $($Record.GetType().InvokeMember("IntegerData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @($Index))))
                Break
              }
              "V"
              {
                $NewObject.Add($($Columns[$Index].Name), $($Record.GetType().InvokeMember("DataSize", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @($Index))))
                Break
              }
              "O"
              {
                $NewObject.Add($($Columns[$Index].Name), $($Record.GetType().InvokeMember("DataSize", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @($Index))))
                Break
              }
              Default
              {
                $NewObject.Add($($Columns[$Index].Name), $Columns[$Index].Type)
                Break
              }
            }
          }
        }
        [PSCustomObject]$NewObject
      }
      [Void]$View.GetType().InvokeMember("Close", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
    }
    [Void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  $View = $Null
  $Record = $Null
  $Query = $Null
  $Columns = $Null
  $NewObject = $Null
  $ColumnNames = $Null
  $ColumnTypes = $Null
  $FieldCount = $Null
  [System.GC]::Collect()
  [System.GC]::WaitForPendingFinalizers()
  Write-Verbose -Message "Exit Function Get-MyMSITable"
}
#endregion

#region function Remove-MyMSITable
function Remove-MyMSITable()
{
  <#
    .SYNOPSIS
      Delete a Table from an Open MSI Database
    .DESCRIPTION
      Delete a Table from an Open MSI Database
    .PARAMETER Database
    .PARAMETER Table
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Remove-MyMSITable -Table "Property"
    .EXAMPLE
      Remove-MyMSITable -Database $MyMSIDatabase -Table "Property"
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Database = $Script:MyMSIDatabase,
    [parameter(Mandatory = $True)]
    [String]$Table,
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Remove-MyMSITable"
  $Query = "DROP TABLE ``$Table``"
  Try
  {
    if ($Alt)
    {
      $View = $Database.Database.OpenView($Query)
      [Void]$View.Execute()
      [Void]$View.Close()
    }
    else
    {
      $View = $Database.Database.GetType().InvokeMember("OpenView", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Database.Database, @($Query))
      [Void]$View.GetType().InvokeMember("Execute", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
      [Void]$View.GetType().InvokeMember("Close", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
    }
    [Void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  $View = $Null
  $Record = $Null
  $Query = $Null
  [System.GC]::Collect()
  [System.GC]::WaitForPendingFinalizers()
  Write-Verbose -Message "Exit Function Remove-MyMSITable"
}
#endregion

#region function New-MyMSITable
function New-MyMSITable()
{
  <#
    .SYNOPSIS
      Creates a New Table in an Open MSI Database
  
      While the Function Works if is only included as a Sample Funcation on how to Create a Table
  
    .DESCRIPTION
      Creates a New Table in an Open MSI Database
    .PARAMETER Database
    .PARAMETER Table
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      New-MyMSITable -Table "Property"
    .EXAMPLE
      New-MyMSITable -Database $MyMSIDatabase -Table "Property"
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Database = $Script:MyMSIDatabase,
    [parameter(Mandatory = $True)]
    [String]$Table,
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function New-MyMSITable"
  $Query = "CREATE TABLE ``$Table`` (``PrimaryKey`` CHAR(64) NOT NULL, ``Field02`` CHARACTER(64), ``Field03`` LONGCHAR, ``Field04`` SHORT, ``Field05`` INT NOT NULL, ``Field06`` INTEGER, ``Field07`` LONG, ``Field08`` OBJECT, ``Field09`` CHAR(64) NOT NULL LOCALIZABLE, ``Field10`` CHARACTER(64) NOT NULL LOCALIZABLE, ``Field11`` LONGCHAR LOCALIZABLE PRIMARY KEY ``PrimaryKey``)"
  Try
  {
    if ($Alt)
    {
      $View = $Database.Database.OpenView($Query)
      [Void]$View.Execute()
      [Void]$View.Close()
    }
    else
    {
      $View = $Database.Database.GetType().InvokeMember("OpenView", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Database.Database, @($Query))
      [Void]$View.GetType().InvokeMember("Execute", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
      [Void]$View.GetType().InvokeMember("Close", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
    }
    [Void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  $View = $Null
  $Record = $Null
  $Query = $Null
  [System.GC]::Collect()
  [System.GC]::WaitForPendingFinalizers()
  Write-Verbose -Message "Exit Function New-MyMSITable"
}
#endregion

#region function Update-MyMSITable
function Update-MyMSITable()
{
  <#
    .SYNOPSIS
      Alter an Existing Table in an Open MSI Database
  
      While the Function Works if is only included as a Sample Funcation on how to Alter a Table
  
    .DESCRIPTION
      Alter an Existing Table in an Open MSI Database
    .PARAMETER Database
    .PARAMETER Table
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Update-MyMSITable -Table "Property"
    .EXAMPLE
      Update-MyMSITable -Database $MyMSIDatabase -Table "Property"
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Database = $Script:MyMSIDatabase,
    [parameter(Mandatory = $True)]
    [String]$Table,
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Update-MyMSITable"
  $Query = "ALTER TABLE ``$Table`` ADD ``Alter01`` CHAR(64) NOT NULL TEMPORARY, ``Alter02`` CHARACTER(64) TEMPORARY, ``Alter03`` LONG NOT NULL TEMPORARY, ``Alter04`` INT TEMPORARY"
  Try
  {
    if ($Alt)
    {
      $View = $Database.Database.OpenView($Query)
      [Void]$View.Execute()
      [Void]$View.Close()
    }
    else
    {
      $View = $Database.Database.GetType().InvokeMember("OpenView", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Database.Database, @($Query))
      [Void]$View.GetType().InvokeMember("Execute", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
      [Void]$View.GetType().InvokeMember("Close", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
    }
    [Void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  $View = $Null
  $Record = $Null
  $Query = $Null
  [System.GC]::Collect()
  [System.GC]::WaitForPendingFinalizers()
  Write-Verbose -Message "Exit Function Update-MyMSITable"
}
#endregion

#region function Lock-MyMSITable
function Lock-MyMSITable()
{
  <#
    .SYNOPSIS
      Hold in Memory a Table from an Open MSI Database
    .DESCRIPTION
      Hold in Memory a Table from an Open MSI Database
    .PARAMETER Database
    .PARAMETER Table
    .PARAMETER Free
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Lock-MyMSITable -Table "Property"
    .EXAMPLE
      Lock-MyMSITable -Database $MyMSIDatabase -Table "Property"
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Database = $Script:MyMSIDatabase,
    [parameter(Mandatory = $True)]
    [String]$Table,
    [Switch]$Free,
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Lock-MyMSITable"
  if ($Free)
  {
    $Query = "ALTER TABLE ``$Table`` FREE"
  }
  else
  {
    $Query = "ALTER TABLE ``$Table`` HOLD"
  }
  Try
  {
    if ($Alt)
    {
      $View = $Database.Database.OpenView($Query)
      [Void]$View.Execute()
      [Void]$View.Close()
    }
    else
    {
      $View = $Database.Database.GetType().InvokeMember("OpenView", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Database.Database, @($Query))
      [Void]$View.GetType().InvokeMember("Execute", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
      [Void]$View.GetType().InvokeMember("Close", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
    }
    [Void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  $View = $Null
  $Record = $Null
  $Query = $Null
  [System.GC]::Collect()
  [System.GC]::WaitForPendingFinalizers()
  Write-Verbose -Message "Exit Function Lock-MyMSITable"
}
#endregion

#region function Get-MyMSIPrimaryKey
function Get-MyMSIPrimaryKey()
{
  <#
    .SYNOPSIS
      Gets the Primary keys of a Table from an Open MSI Database
    .DESCRIPTION
      Gets the Primary keys of a Table from an Open MSI Database
    .PARAMETER Database
    .PARAMETER Table
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Get-MyMSIPrimaryKey -Table "Property"
    .EXAMPLE
      Get-MyMSIPrimaryKey -Database $MyMSIDatabase -Table "Property"
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Database = $Script:MyMSIDatabase,
    [parameter(Mandatory = $True)]
    [String]$Table,
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Get-MyMSIPrimaryKey"
  Try
  {
    if ($Alt)
    {
      $Record = $Database.Database.PrimaryKeys($Table)
      $FieldCount = $Record.FieldCount()
      $PrimaryKeys = New-Object -TypeName System.Collections.ArrayList
      For ($Index = 1; $Index -le $FieldCount; $Index++)
      {
        [Void]$PrimaryKeys.Add($Record.StringData($Index))
      }
    }
    else
    {
      $Record = $Database.Database.GetType().InvokeMember("PrimaryKeys", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Database.Database, @($Table))
      $FieldCount = $Record.GetType().InvokeMember("FieldCount", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, $Null)
      $PrimaryKeys = New-Object -TypeName System.Collections.ArrayList
      For ($Index = 1; $Index -le $FieldCount; $Index++)
      {
        [Void]$PrimaryKeys.Add($Record.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @($Index)))
      }
    }
    [PSCustomObject]@{
      "Table" = $Table;
      "Count" = $FieldCount;
      "PrimaryKeys" = $PrimaryKeys
    }
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  $PrimaryKeys = $Null
  $Record = $Null
  $FieldCount = $Null
  $Index = $Null
  Write-Verbose -Message "Exit Function Get-MyMSIPrimaryKey"
}
#endregion

#region function Update-MyMSIPropertyTable
function Update-MyMSIPropertyTable()
{
  <#
    .SYNOPSIS
      Inset, Update, or Delete a Propery Value in the Property Table of an Open MSI Database
    .DESCRIPTION
      Inset, Update, or Delete a Propery Value in the Property Table of an Open MSI Database
    .PARAMETER Database
    .PARAMETER Propery
    .PARAMETER Value
    .PARAMETER Type
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Get-MyMSITable -Propery "Property" -Value "Value"
    .EXAMPLE
      Get-MyMSITable -Propery "Property" -Value "Value" -Update
    .EXAMPLE
      Get-MyMSITable -Propery "Property" -Delete
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Database = $Script:MyMSIDatabase,
    [parameter(Mandatory = $True, ParameterSetName = "Update")]
    [parameter(Mandatory = $True, ParameterSetName = "Delete")]
    [String]$Property,
    [parameter(Mandatory = $True, ParameterSetName = "Update")]
    [String]$Value,
    [ValidateSet("Insert", "Update", "Delete")]
    [String]$Type = "Insert",
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Update-MyMSIPropertyTable"
  Switch ($Type)
  {
    "Insert"
    {
      $Query = "INSERT INTO ``Property`` (``Property``, ``Value``) VALUES ('$Property', '$Value')"
      break
    }
    "Update"
    {
      $Query = "UPDATE ``Property`` SET ``Value`` = '$Value' WHERE ``Property`` = '$Property'"
      break
    }
    "Delete"
    {
      $Query = "DELETE FROM ``Property`` WHERE ``Property`` = '$Property'"
      break
    }
  }
  Try
  {
    if ($Alt)
    {
      $View = $Database.Database.OpenView($Query)
      [Void]$View.Execute()
      [Void]$View.Close()
    }
    else
    {
      $View = $Database.Database.GetType().InvokeMember("OpenView", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Database.Database, @($Query))
      [Void]$View.GetType().InvokeMember("Execute", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
      [Void]$View.GetType().InvokeMember("Close", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
    }
    [Void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  $View = $Null
  $Query = $Null
  [System.GC]::Collect()
  [System.GC]::WaitForPendingFinalizers()
  Write-Verbose -Message "Exit Function Update-MyMSIPropertyTable"
}
#endregion

#region function Export-MyMSITable
function Export-MyMSITable()
{
  <#
    .SYNOPSIS
      Export a Table from an Open MSI Database
    .DESCRIPTION
      Export a Table from an Open MSI Database
    .PARAMETER Database
    .PARAMETER Table
    .PARAMETER Path
    .PARAMETER FileName
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Get-MyMSITable -Table "Property" -Path "C:\Test" -FileName "Property.txt"
    .EXAMPLE
      Get-MyMSITable -Database $MyMSIDatabase -Table "Property" -Path "C:\Test" -FileName "Property.txt"
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Database = $Script:MyMSIDatabase,
    [parameter(Mandatory = $True)]
    [String]$Table,
    [parameter(Mandatory = $True)]
    [ValidateScript({ [IO.Directory]::Exists($PSItem) })]
    [String]$Path,
    [parameter(Mandatory = $True)]
    [String]$FileName,
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Export-MyMSITable"
  Try
  {
    if ($Alt)
    {
      $Database.Database.Export($Table, $Path, $FileName)
    }
    else
    {
      $Database.Database.GetType().InvokeMember("Export", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Database.Database, @($Table, $Path, $FileName))
    }
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  Write-Verbose -Message "Exit Function Export-MyMSITable"
}
#endregion
          
#region function Import-MyMSITable
function Import-MyMSITable()
{
  <#
    .SYNOPSIS
      Import a Table in to an Open MSI Database
    .DESCRIPTION
      Import a Table in to an Open MSI Database
    .PARAMETER Database
    .PARAMETER Table
    .PARAMETER Path
    .PARAMETER FileName
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Get-MyMSITable -Table "Property" -Path "C:\Test" -FileName "Property.txt"
    .EXAMPLE
      Get-MyMSITable -Database $MyMSIDatabase -Table "Property" -Path "C:\Test" -FileName "Property.txt"
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Database = $Script:MyMSIDatabase,
    [parameter(Mandatory = $True)]
    [ValidateScript({ [IO.Directory]::Exists($PSItem) })]
    [String]$Path,
    [parameter(Mandatory = $True)]
    [String]$FileName,
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Import-MyMSITable"
  Try
  {
    if ($Alt)
    {
      $Database.Database.Export($Path, $FileName)
    }
    else
    {
      $Database.Database.GetType().InvokeMember("Import", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Database.Database, @($Path, $FileName))
    }
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  Write-Verbose -Message "Exit Function Import-MyMSITable"
}
#endregion

#region function Get-MyMSISummaryInfo
function Get-MyMSISummaryInfo()
{
  <#
    .SYNOPSIS
      Get the SummaryInfo from an Open MSI Database
    .DESCRIPTION
      Get the SummaryInfo from an Open MSI Database
    .PARAMETER Database
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Get-MyMSISummaryInfo -Database $MyMSIDatabase
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Database = $Script:MyMSIDatabase,
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Get-MyMSISummaryInfo"
  Try
  {
    if ($Alt)
    {
      $SummaryInfo = $Database.Database.SummaryInformation()
      [PSCustomObject]@{
        "Codepage" = $SummaryInfo.Property(1);
        "Title" = $SummaryInfo.Property(2);
        "Subject" = $SummaryInfo.Property(3);
        "Author" = $SummaryInfo.Property(4);
        "Keywords" = $SummaryInfo.Property(5);
        "Comments" = $SummaryInfo.Property(6);
        "Template" = $SummaryInfo.Property(7);
        "LastAuthor" = $SummaryInfo.Property(8);
        "Revision" = $SummaryInfo.Property(9);
        "Printed" = $SummaryInfo.Property(11);
        "Created" = $SummaryInfo.Property(12);
        "Saved" = $SummaryInfo.Property(13);
        "Pages" = $SummaryInfo.Property(14);
        "Words" = $SummaryInfo.Property(15);
        "Characters" = $SummaryInfo.Property(16);
        "Application" = $SummaryInfo.Property(18);
        "Security" = $SummaryInfo.Property(19)
      }
    }
    else
    {
      $SummaryInfo = $Database.Database.GetType().InvokeMember("SummaryInformation", [System.Reflection.BindingFlags]::GetProperty, $Null, $Database.Database, $Null)
      [PSCustomObject]@{
        "Codepage" = $($SummaryInfo.GetType().InvokeMember("Property", [System.Reflection.BindingFlags]::GetProperty, $Null, $SummaryInfo, @(1)));
        "Title" = $($SummaryInfo.GetType().InvokeMember("Property", [System.Reflection.BindingFlags]::GetProperty, $Null, $SummaryInfo, @(2)));
        "Subject" = $($SummaryInfo.GetType().InvokeMember("Property", [System.Reflection.BindingFlags]::GetProperty, $Null, $SummaryInfo, @(3)));
        "Author" = $($SummaryInfo.GetType().InvokeMember("Property", [System.Reflection.BindingFlags]::GetProperty, $Null, $SummaryInfo, @(4)));
        "Keywords" = $($SummaryInfo.GetType().InvokeMember("Property", [System.Reflection.BindingFlags]::GetProperty, $Null, $SummaryInfo, @(5)));
        "Comments" = $($SummaryInfo.GetType().InvokeMember("Property", [System.Reflection.BindingFlags]::GetProperty, $Null, $SummaryInfo, @(6)));
        "Template" = $($SummaryInfo.GetType().InvokeMember("Property", [System.Reflection.BindingFlags]::GetProperty, $Null, $SummaryInfo, @(7)));
        "LastAuthor" = $($SummaryInfo.GetType().InvokeMember("Property", [System.Reflection.BindingFlags]::GetProperty, $Null, $SummaryInfo, @(8)));
        "Revision" = $($SummaryInfo.GetType().InvokeMember("Property", [System.Reflection.BindingFlags]::GetProperty, $Null, $SummaryInfo, @(9)));
        "Printed" = $($SummaryInfo.GetType().InvokeMember("Property", [System.Reflection.BindingFlags]::GetProperty, $Null, $SummaryInfo, @(11)));
        "Created" = $($SummaryInfo.GetType().InvokeMember("Property", [System.Reflection.BindingFlags]::GetProperty, $Null, $SummaryInfo, @(12)));
        "Saved" = $($SummaryInfo.GetType().InvokeMember("Property", [System.Reflection.BindingFlags]::GetProperty, $Null, $SummaryInfo, @(13)));
        "Pages" = $($SummaryInfo.GetType().InvokeMember("Property", [System.Reflection.BindingFlags]::GetProperty, $Null, $SummaryInfo, @(14)));
        "Words" = $($SummaryInfo.GetType().InvokeMember("Property", [System.Reflection.BindingFlags]::GetProperty, $Null, $SummaryInfo, @(15)));
        "Characters" = $($SummaryInfo.GetType().InvokeMember("Property", [System.Reflection.BindingFlags]::GetProperty, $Null, $SummaryInfo, @(16)));
        "Application" = $($SummaryInfo.GetType().InvokeMember("Property", [System.Reflection.BindingFlags]::GetProperty, $Null, $SummaryInfo, @(18)));
        "Security" = $($SummaryInfo.GetType().InvokeMember("Property", [System.Reflection.BindingFlags]::GetProperty, $Null, $SummaryInfo, @(19)))
      }
    }
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  $SummaryInfo = $Null
  Write-Verbose -Message "Exit Function Get-MyMSISummaryInfo"
}
#endregion

#region function Merge-MyMSITransform
function Merge-MyMSITransform()
{
  <#
    .SYNOPSIS
      Apply a Transform File to an Open MSI Datanase
    .DESCRIPTION
      Apply a Transform File to an Open MSI Datanase
    .PARAMETER Database
    .PARAMETER MST
    .PARAMETER TransformView
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Merge-MyMSITransform -MST "C:\Test\MyMST.mst"
    .EXAMPLE
      Merge-MyMSITransform -Database $MyMSIDatabase -MST "C:\Test\MyMST.mst" -TransformView
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Database = $Script:MyMSIDatabase,
    [parameter(Mandatory = $True)]
    [ValidateScript({ [IO.File]::Exists($PSItem) })]
    [String]$MST,
    [Switch]$TransformView,
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Merge-MyMSITransform"
  if ($TransformView)
  {
    $Conditions = 319
  }
  else
  {
    $Conditions = 63
  }
  Try
  {
    if ($Alt)
    {
      $Database.Database.ApplyTransform($MST, $Conditions)
    }
    else
    {
      $Database.Database.GetType().InvokeMember("ApplyTransform", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Database.Database, @($MST, $Conditions))
    }
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  $Conditions = $Null
  [System.GC]::Collect()
  [System.GC]::WaitForPendingFinalizers()
  Write-Verbose -Message "Exit Function Merge-MyMSITransform"
}
#endregion

#region function New-MyMSITransform
function New-MyMSITransform()
{
  <#
    .SYNOPSIS
      Generate a MST Transform File
    .DESCRIPTION
      Generate a MST Transform File
    .PARAMETER Database
    .PARAMETER Reference
    .PARAMETER MST
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Merge-MyMSITransform -Database $MyMSIDatabase -Reference $MyMSIReference -MST "C:\Test\MyMST.mst"
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Database = $Script:MyMSIDatabase,
    [parameter(Mandatory = $True)]
    [Object]$Reference,
    [parameter(Mandatory = $True)]
    [String]$MST,
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function New-MyMSITransform"
  $Generate = $False
  Try
  {
    if ($Alt)
    {
      $Database.Database.GenerateTransform($Reference.Database, $MST)
    }
    else
    {
      $Database.Database.GetType().InvokeMember("GenerateTransform", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Database.Database, @($Reference.Database, $MST))
    }
      $Generate = $True
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  [PSCustomObject]@{"Generate" = $Generate}
  Write-Verbose -Message "Exit Function New-MyMSITransform"
}
#endregion

#region function Get-MyMSIBinary
function Get-MyMSIBinary()
{
  <#
    .SYNOPSIS
      Read Stream from the Binary Table in in Open MSI Database
    .DESCRIPTION
      Read Stream from the Binary Table in in Open MSI Database
    .PARAMETER Database
    .PARAMETER Name
    .PARAMETER List
    .PARAMETER Format
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Get-MyMSIBinary -List
    .EXAMPLE
      Get-MyMSIBinary -Name "BinaryData"
      Original Function By Ken Sweet
            
      $Format
      0 = long integer the length must be 1 to 4
      1 = data as a BSTR—one byte per character
      2 = ANSI bytes translated to a Unicode BSTR
      3 = byte pairs that are returned directly as a BSTR
    .LINK
  #>
  [CmdletBinding(DefaultParameterSetName = "ReadStream")]
  param (
    [Object]$Database = $Script:MyMSIDatabase,
    [parameter(Mandatory = $True, ParameterSetName = "ReadStream")]
    [String]$Name,
    [parameter(Mandatory = $True, ParameterSetName = "List")]
    [Switch]$List,
    [parameter(ParameterSetName = "ReadStream")]
    [ValidateSet(0, 1, 2, 3)]
    [String]$Format = 1,
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Get-MyMSIBinary"
  If ($PSCmdlet.ParameterSetName -eq "ReadStream")
  {
    $Query = "SELECT * FROM Binary WHERE ``Name`` = '$Name'"
  }
  else
  {
    $Query = "SELECT * FROM Binary Order By ``Name``"
  }
  Try
  {
    if ($Alt)
    {
      $View = $Database.Database.OpenView($Query)
      [Void]$View.Execute()
      If ($PSCmdlet.ParameterSetName -eq "ReadStream")
      {
        While (($Record = $View.Fetch()))
        {
          $DataSize = $Record.DataSize(2)
          [PSCustomObject]@{
            "Name" = $Record.StringData(1);
            "DataSize" = $DataSize;
            "Data" = $Record.ReadStream(2, $DataSize, $Format)
          }
        }
      }
      else
      {
        While (($Record = $View.Fetch()))
        {
          [PSCustomObject]@{
            "Name" = $Record.StringData(1);
            "DataSize" = $Record.DataSize(2)
          }
        }
      }
      [Void]$View.Close()
    }
    else
    {
      $View = $Database.Database.GetType().InvokeMember("OpenView", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Database.Database, @($Query))
      [Void]$View.GetType().InvokeMember("Execute", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
      If ($PSCmdlet.ParameterSetName -eq "ReadStream")
      {
        While (($Record = $View.GetType().InvokeMember("Fetch", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)))
        {
          $DataSize = $Record.GetType().InvokeMember("DataSize", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @(2))
          [PSCustomObject]@{
            "Name" = $Record.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @(1));
            "DataSize" = $DataSize;
            "Data" = $Record.GetType().InvokeMember("ReadStream", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Record, @(2, $DataSize, $Format))
          }
        }
      }
      else
      {
        While (($Record = $View.GetType().InvokeMember("Fetch", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)))
        {
          [PSCustomObject]@{
            "Name" = $Record.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @(1));
            "DataSize" = $Record.GetType().InvokeMember("DataSize", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @(2))
          }
        }
      }
      [Void]$View.GetType().InvokeMember("Close", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
    }
    [Void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  $View = $Null
  $Record = $Null
  $Query = $Null
  $DataSize = $Null
  [System.GC]::Collect()
  [System.GC]::WaitForPendingFinalizers()
  Write-Verbose -Message "Exit Function Get-MyMSIBinary"
}
#endregion

#region function Set-MyMSIBinary
function Set-MyMSIBinary()
{
  <#
    .SYNOPSIS
      Write Stream to the Binary Table in in Open MSI Database
    .DESCRIPTION
      Write Stream to the Binary Table in in Open MSI Database
    .PARAMETER Database
    .PARAMETER Path
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Set-MyMSIBinary -List
    .EXAMPLE
      Set-MyMSIBinary -Name "BinaryData"
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Installer = $Script:MyInstaller,
    [Object]$Database = $Script:MyMSIDatabase,
    [parameter(Mandatory = $True)]
    [String]$Name,
    [ValidateScript({ [IO.File]::Exists($PSItem) })]
    [String]$Path,
    [ValidateSet("Insert", "Update", "Delete")]
    [String]$Mode = "Insert",
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Set-MyMSIBinary"
  Switch ($Mode)
  {
    "Insert"
    {
      $Action = 1
      Break
    }
    "Update"
    {
      $Action = 2
      Break
    }
    "Replace"
    {
      $Action = 4
      Break
    }
    "Delete"
    {
      $Action = 6
      Break
    }
  }
  If ($Mode -eq "Insert")
  {
    $Query = "SELECT * FROM Binary"
  }
  else
  {
    $Query = "SELECT * FROM Binary WHERE ``Name`` = '$Name'"
  }
  Try
  {
    if ($Alt)
    {
      $View = $Database.Database.OpenView($Query)
      Switch ($Mode)
      {
        "Insert"
        {
          $Record = $Installer.Installer.CreateRecord(2)
          $Record.StringData(1) = $Name
          [Void]$View.Execute($Record)
          $Record.SetStream(2, $Path)
          Break
        }
        "Update"
        {
          $Record = $View.Execute()
          $Record = $View.Fetch()
          $Record.SetStream(2, $Path)
          Break
        }
        "Delete"
        {
          $Record = $View.Execute()
          $Record = $View.Fetch()
          Break
        }
      }
      $View.Modify($Action, $Record)
      [Void]$View.Close()
    }
    else
    {
      $View = $Database.Database.GetType().InvokeMember("OpenView", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Database.Database, @($Query))
      Switch ($Mode)
      {
        "Insert"
        {
          $Record = $Installer.Installer.GetType().InvokeMember("CreateRecord", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Installer.Installer, @(2))
          [Void]$Record.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::SetProperty, $Null, $Record, @(1, $Name));
          [Void]$View.GetType().InvokeMember("Execute", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, @($Record))
          [Void]$Record.GetType().InvokeMember("SetStream", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Record, @(2, $Path));
          Break
        }
        "Update"
        {
          [Void]$View.GetType().InvokeMember("Execute", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
          $Record = $View.GetType().InvokeMember("Fetch", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
          [Void]$Record.GetType().InvokeMember("SetStream", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Record, @(2, $Path));
          Break
        }
        "Delete"
        {
          [Void]$View.GetType().InvokeMember("Execute", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
          $Record = $View.GetType().InvokeMember("Fetch", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
          Break
        }
      }
      [Void]$View.GetType().InvokeMember("Modify", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, @($Action, $Record))
      [Void]$View.GetType().InvokeMember("Close", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
    }
    [Void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  $View = $Null
  $Record = $Null
  $Query = $Null
  $DataSize = $Null
  [System.GC]::Collect()
  [System.GC]::WaitForPendingFinalizers()
  Write-Verbose -Message "Exit Function Set-MyMSIBinary"
}
#endregion

#region function Get-MyMSIStream
function Get-MyMSIStream()
{
  <#
    .SYNOPSIS
      Read Stream from the _Streams Table in in Open MSI Database
    .DESCRIPTION
      Read Stream from the _Streams Table in in Open MSI Database
    .PARAMETER Database
    .PARAMETER Name
    .PARAMETER List
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Get-MyMSIStream -List
    .EXAMPLE
      Get-MyMSIStream -Name "BinaryData"
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding(DefaultParameterSetName = "ReadStream")]
  param (
    [Object]$Database = $Script:MyMSIDatabase,
    [parameter(Mandatory = $True, ParameterSetName = "ReadStream")]
    [String]$Name,
    [parameter(Mandatory = $True, ParameterSetName = "List")]
    [Switch]$List,
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Get-MyMSIStream"
  If ($PSCmdlet.ParameterSetName -eq "ReadStream")
  {
    $Query = "SELECT * FROM _Streams WHERE ``Name`` = '$Name'"
  }
  else
  {
    $Query = "SELECT * FROM _Streams Order By ``Name``"
  }
  Try
  {
    if ($Alt)
    {
      $View = $Database.Database.OpenView($Query)
      [Void]$View.Execute()
      If ($PSCmdlet.ParameterSetName -eq "ReadStream")
      {
        While (($Record = $View.Fetch()))
        {
          $DataSize = $Record.DataSize(2)
          [PSCustomObject]@{
            "Name" = $Record.StringData(1);
            "DataSize" = $DataSize;
            "Data" = $Record.ReadStream(2, $DataSize, 1)
          }
        }
      }
      else
      {
        While (($Record = $View.Fetch()))
        {
          [PSCustomObject]@{
            "Name" = $Record.StringData(1);
            "DataSize" = $Record.DataSize(2)
          }
        }
      }
      [Void]$View.Close()
    }
    else
    {
      $View = $Database.Database.GetType().InvokeMember("OpenView", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Database.Database, @($Query))
      [Void]$View.GetType().InvokeMember("Execute", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
      If ($PSCmdlet.ParameterSetName -eq "ReadStream")
      {
        While (($Record = $View.GetType().InvokeMember("Fetch", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)))
        {
          $DataSize = $Record.GetType().InvokeMember("DataSize", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @(2))
          [PSCustomObject]@{
            "Name" = $Record.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @(1));
            "DataSize" = $DataSize;
            "Data" = $Record.GetType().InvokeMember("ReadStream", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Record, @(2, $DataSize, 1))
          }
        }
      }
      else
      {
        While (($Record = $View.GetType().InvokeMember("Fetch", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)))
        {
          [PSCustomObject]@{
            "Name" = $Record.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @(1));
            "DataSize" = $Record.GetType().InvokeMember("DataSize", [System.Reflection.BindingFlags]::GetProperty, $Null, $Record, @(2))
          }
        }
      }
      [Void]$View.GetType().InvokeMember("Close", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
    }
    [Void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  $View = $Null
  $Record = $Null
  $Query = $Null
  $DataSize = $Null
  [System.GC]::Collect()
  [System.GC]::WaitForPendingFinalizers()
  Write-Verbose -Message "Exit Function Get-MyMSIStream"
}
#endregion

#region function Set-MyMSIStream
function Set-MyMSIStream()
{
  <#
    .SYNOPSIS
      Write Stream to the _Stream Table in in Open MSI Database
    .DESCRIPTION
      Write Stream to the _Stream Table in in Open MSI Database
    .PARAMETER Database
    .PARAMETER Path
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Set-MyMSIStream -List
    .EXAMPLE
      Set-MyMSIStream -Name "StreamData"
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Installer = $Script:MyInstaller,
    [Object]$Database = $Script:MyMSIDatabase,
    [parameter(Mandatory = $True)]
    [String]$Name,
    [ValidateScript({ [IO.File]::Exists($PSItem) })]
    [String]$Path,
    [ValidateSet("Insert", "Update", "Delete")]
    [String]$Mode = "Insert",
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Set-MyMSIStream"
  Switch ($Mode)
  {
    "Insert"
    {
      $Action = 1
      Break
    }
    "Update"
    {
      $Action = 2
      Break
    }
    "Replace"
    {
      $Action = 4
      Break
    }
    "Delete"
    {
      $Action = 6
      Break
    }
  }
  If ($Mode -eq "Insert")
  {
    $Query = "SELECT * FROM _Stream"
  }
  else
  {
    $Query = "SELECT * FROM _Stream WHERE ``Name`` = '$Name'"
  }
  Try
  {
    if ($Alt)
    {
      $View = $Database.Database.OpenView($Query)
      Switch ($Mode)
      {
        "Insert"
        {
          $Record = $Installer.Installer.CreateRecord(2)
          $Record.StringData(1) = $Name
          [Void]$View.Execute($Record)
          $Record.SetStream(2, $Path)
          Break
        }
        "Update"
        {
          $Record = $View.Execute()
          $Record = $View.Fetch()
          $Record.SetStream(2, $Path)
          Break
        }
        "Delete"
        {
          $Record = $View.Execute()
          $Record = $View.Fetch()
          Break
        }
      }
      $View.Modify($Action, $Record)
      [Void]$View.Close()
    }
    else
    {
      $View = $Database.Database.GetType().InvokeMember("OpenView", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Database.Database, @($Query))
      Switch ($Mode)
      {
        "Insert"
        {
          $Record = $Installer.Installer.GetType().InvokeMember("CreateRecord", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Installer.Installer, @(2))
          [Void]$Record.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::SetProperty, $Null, $Record, @(1, $Name));
          [Void]$View.GetType().InvokeMember("Execute", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, @($Record))
          [Void]$Record.GetType().InvokeMember("SetStream", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Record, @(2, $Path));
          Break
        }
        "Update"
        {
          [Void]$View.GetType().InvokeMember("Execute", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
          $Record = $View.GetType().InvokeMember("Fetch", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
          [Void]$Record.GetType().InvokeMember("SetStream", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Record, @(2, $Path));
          Break
        }
        "Delete"
        {
          [Void]$View.GetType().InvokeMember("Execute", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
          $Record = $View.GetType().InvokeMember("Fetch", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
          Break
        }
      }
      [Void]$View.GetType().InvokeMember("Modify", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, @($Action, $Record))
      [Void]$View.GetType().InvokeMember("Close", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $View, $Null)
    }
    [Void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($View)
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  $View = $Null
  $Record = $Null
  $Query = $Null
  $DataSize = $Null
  [System.GC]::Collect()
  [System.GC]::WaitForPendingFinalizers()
  Write-Verbose -Message "Exit Function Set-MyMSIStream"
}
#endregion

#region function Show-MyMSIUIPreview
function Show-MyMSIUIPreview()
{
  <#
    .SYNOPSIS
  
      You can only Display one Dialog at a Time
  
    .DESCRIPTION
    .PARAMETER Database
    .PARAMETER Dialog
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Show-MyMSIUIPreview -Database $MyMSIDatabase -Dialog "MyDialog"
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Object]$Database = $Script:MyMSIDatabase,
    [parameter(Mandatory = $True)]
    [String]$Dialog,
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Show-MyMSIUIPreview"
  Try
  {
    $Dialogs = Get-MyMSITable -Database $Database -Table "Dialog" -Property "Dialog" -Value $Dialog -Alt:$Alt
    $DefProperties = Get-MyMSITable -Database $Database -Table "Property" -Alt:$Alt
    if ($Alt)
    {
      $Script:MyUIPreview = $Database.Database.EnableUIPreview()
      ForEach ($DefProperty in $DefProperties)
      {
        $Script:MyUIPreview.Property($DefProperty.Property) = $DefProperty.Value
      }
      $Script:MyUIPreview.ViewDialog($Dialogs.Dialog)
    }
    else
    {
      $Script:MyUIPreview = $Database.Database.GetType().InvokeMember("EnableUIPreview", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Database.Database, $Null)
      ForEach ($DefProperty in $DefProperties)
      {
        $Script:MyUIPreview.GetType().InvokeMember("Property", [System.Reflection.BindingFlags]::SetProperty, $Null, $Script:MyUIPreview, @($DefProperty.Property, $DefProperty.Value))
      }
      [Void]$Script:MyUIPreview.GetType().InvokeMember("ViewDialog", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Script:MyUIPreview, @($Dialogs.Dialog))
    }
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  $Dialogs = $Null
  $DefProperties = $Null
  $DefProperty = $Null
  Write-Verbose -Message "Exit Function Show-MyMSIUIPreview"
}
#endregion

#region function Close-MyMSIUIPreview
function Close-MyMSIUIPreview()
{
  <#
    .SYNOPSIS
      Close an Open Dialog
    .DESCRIPTION
      Close an Open Dialog
    .PARAMETER Alt
    .INPUTS
    .OUTPUTS
    .EXAMPLE
      Close-MyMSIUIPreview
    .EXAMPLE
      Close-MyMSIUIPreview -Alt
      Original Function By Ken Sweet
    .LINK
  #>
  [CmdletBinding()]
  param (
    [Switch]$Alt
  )
  Write-Verbose -Message "Enter Function Close-MyMSIUIPreview"
  Try
  {
    if ($Alt)
    {
      $Script:MyUIPreview.ViewDialog("")
    }
    else
    {
      [Void]$Script:MyUIPreview.GetType().InvokeMember("ViewDialog", [System.Reflection.BindingFlags]::InvokeMethod, $Null, $Script:MyUIPreview, @(""))
    }
    [Void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($Script:MyUIPreview)
  }
  Catch
  {
    Write-Debug -Message "ErrMsg: $($Error[0].Exception.Message)"
    Write-Debug -Message "Line: $($Error[0].InvocationInfo.ScriptLineNumber)"
    Write-Debug -Message "Code: $(($Error[0].InvocationInfo.Line).Trim())"
  }
  $Script:MyUIPreview = $Null
  [System.GC]::Collect()
  [System.GC]::WaitForPendingFinalizers()
  Write-Verbose -Message "Exit Function Close-MyMSIUIPreview"
}
#endregion

#endregion


# Create the Windows Installer COM Object
If (($WindowsInstaller = Open-MyWindowsInstaller -PassThru).Connect)
{
  Write-Host
  Write-Host -ForegroundColor "DarkGreen" -Object "Successfully Created Windows Installer COM Object"
  Write-Host
  Write-Host -ForegroundColor "White" -Object "Windows Installer Version: $($WindowsInstaller.Version.ToString())"
  Write-Host
  
  # Show Installed Products
  Get-MyInstallerProduct -Installer $WindowsInstaller -AllUsers | Format-Table -AutoSize -Property *
  
  # Show Installed Patches for aoo products
  Get-MyProductGUID -Installer $WindowsInstaller | ForEach-Object -Process { Get-MyProductPatch -Installer $WindowsInstaller -ProductID "$PSItem" } | Format-Table -AutoSize -Property *
  
  # Open Copy of MSI Database
  If (($MSIDatabase = Open-MyMSIDatabase -Installer $WindowsInstaller -Path $WorkingMSI -Mode "ReadWrite" -PassThru).Connect)
  {
    Write-Host -ForegroundColor "DarkGreen" -Object "Successfully Opened Windows Installer Database"
    
    # Show MSI Summary Information
    Get-MyMSISummaryInfo -Database $MSIDatabase | Format-List -Property *
    
    # Show Table Colums
    Get-MyMSITableColumn -Database $MSIDatabase -Table "Dialog" | Format-Table -AutoSize -Property *
    
    # Show Table Validation Informatin
    Get-MyMSIValidation -Database $MSIDatabase -Table "Dialog" | Format-Table -AutoSize -Property *
    
    # Check if Table Exists
    Confirm-MyMSITablePersistent -Database $MSIDatabase -Table "MyTable" | Format-Table -AutoSize -Property *
    
    # Create a new MSI table
    New-MyMSITable -Database $MSIDatabase -Table "MyTable"
    
    # Show New Table Comumn Data Types
    Get-MyMSITableColumnType -Database $MSIDatabase -Table "MyTable" | Format-Table -AutoSize -Property *
    
    # Hold Table to make Tempary Changes
    Lock-MyMSITable -Database $MSIDatabase -Table "MyTable"
    
    # Update Table with new Temporary Fields
    Update-MyMSITable -Database $MSIDatabase -Table "MyTable"
    
    # Show New Table Comumn Data Types with Temporary Columns
    Get-MyMSITableColumnType -Database $MSIDatabase -Table "MyTable" | Format-Table -AutoSize -Property *
    
    # Free Table, Revert All Temporary Columns
    Lock-MyMSITable -Database $MSIDatabase -Table "MyTable" -Free
    
    # Show Restored Table Comumn Data Types
    Get-MyMSITableColumnType -Database $MSIDatabase -Table "MyTable" | Format-Table -AutoSize -Property *
    
    # Show Table Primary Keys
    Get-MyMSIPrimaryKey -Database $MSIDatabase -Table "Dialog" | Format-Table -AutoSize -Property *
    
    # Check if Table Exists
    Confirm-MyMSITablePersistent -Database $MSIDatabase -Table "MyTable" | Format-Table -AutoSize -Property *
    
    # Export a Table to a Text File
    Export-MyMSITable -Database $MSIDatabase -Table "Property" -Path $ENV:TEMP -FileName $ExportFile
              
    # Remove A from the MSI Database
    Remove-MyMSITable -Database $MSIDatabase -Table "Property"
              
    # Import a Table to a Text File
    Import-MyMSITable -Database $MSIDatabase -Path $ENV:TEMP -FileName $ExportFile
              
    # Add Text File a new Binary Stream
    Set-MyMSIBinary -Database $MSIDatabase -Name $ExportFile -Path "$($ENV:TEMP)\$ExportFile"
    
    # Show New Binary Stream was added
    Get-MyMSIBinary -Database $MSIDatabase -List | Format-Table -AutoSize -Property *
    
    # Show original Property Value
    Get-MyMSITable -Database $MSIDatabase -Table "Property" -Property "Property" -Value "Manufacturer" | Format-Table -AutoSize -Property *
    
    # Update Property Value
    Update-MyMSIPropertyTable -Database $MSIDatabase -Property "Manufacturer" -Value "$($ENV:USERNAME)" -Type "Update"
    
    # Show Updated Property Value
    Get-MyMSITable -Database $MSIDatabase -Table "Property" -Property "Property" -Value "Manufacturer" | Format-Table -AutoSize -Property *
    
    # Add New Property
    Update-MyMSIPropertyTable -Database $MSIDatabase -Property "MyProperty" -Value "MyValue" -Type "Insert"
    
    # Show New Property and Value
    Get-MyMSITable -Database $MSIDatabase -Table "Property" -Property "Property" -Value "MyProperty" | Format-Table -AutoSize -Property *
    
    # Get and Show Dialog Table
    ($Dalogs = Get-MyMSITable -Database $MSIDatabase -Table "Dialog") | Format-Table -AutoSize -Property *
    
    # Display the First Dialog
    Show-MyMSIUIPreview -Database $MSIDatabase -Dialog $Dalogs[0].Dialog
    Start-Sleep -Seconds 2
    Close-MyMSIUIPreview
    
    # Commit Changes in the MSI Database
    if ((Save-MyMSIDatabase -Database $MSIDatabase).Commit)
    {
      Write-Host -ForegroundColor "DarkGreen" -Object "Successfully Commited Windows Installer Database"
    }
    else
    {
      Write-Host -ForegroundColor "DarkRed" -Object "Failed to Commited Windows Installer Database"
    }
    
    # Open Original MSI Database
    If (($REFDatabase = Open-MyMSIDatabase -Installer $WindowsInstaller -Path $OriginalMSI -Mode "ReadOnly" -PassThru).Connect)
    {
      Write-Host -ForegroundColor "DarkGreen" -Object "Successfully Opened Windows Installer Database"
      
      # Generate a Transform File
      If ((New-MyMSITransform -Database $MSIDatabase -Reference $REFDatabase -MST $WorkingMST).Generate)
      {
        Write-Host -ForegroundColor "DarkGreen" -Object "Successfully Generated Windows Installer Transform File"
        
        # Merge MST with Original MSI and create the Temporary TransformView Table
        Merge-MyMSITransform -Database $REFDatabase -MST $WorkingMST -TransformView
        
        # Show the Temporary TransformView Table
        Get-MyMSITable -Database $REFDatabase -Table "_TransformView" | Format-Table -AutoSize -Property *
      }
      else
      {
        Write-Host -ForegroundColor "DarkGreen" -Object "Failed to Generate Windows Installer Transform File"
      }
      
      # Close the Original MSI Database
      If ((Close-MyMSIDatabase -Database $REFDatabase -PassThru).Connect)
      {
        Write-Host -ForegroundColor "DarkRed" -Object "Failed to Close Windows Installer Database"
      }
      else
      {
        Write-Host -ForegroundColor "DarkGreen" -Object "Successfully Closed Windows Installer Database"
      }
    }
    else
    {
      Write-Host -ForegroundColor "DarkRed" -Object "Failed to Open Windows Installer Database"
      
      # Show Error is Unable to Open MSI Database
      Get-MyInstallerErrorRecord -Installer $WindowsInstaller | Format-Table -AutoSize -Property *
    }
    
    # Close Copy of MSI Database
    If ((Close-MyMSIDatabase -Database $MSIDatabase -PassThru).Connect)
    {
      Write-Host -ForegroundColor "DarkRed" -Object "Failed to Close Windows Installer Database"
    }
    else
    {
      Write-Host -ForegroundColor "DarkGreen" -Object "Successfully Closed Windows Installer Database"
    }
  }
  else
  {
    Write-Host -ForegroundColor "DarkRed" -Object "Failed to Open Windows Installer Database"
    
    # Show Error is Unable to Open MSI Database
    Get-MyInstallerErrorRecord -Installer $WindowsInstaller | Format-Table -AutoSize -Property *
  }
  
  # Release Windows Installer COM Object
  if ((Close-MyWindowsInstaller -Installer $WindowsInstaller).Connect)
  {
    Write-Host -ForegroundColor "DarkRed" -Object "Failed to Release Windows Installer COM Object"
  }
  else
  {
    Write-Host -ForegroundColor "DarkGreen" -Object "Successfully Released Windows Installer COM Object"
  }
}
else
{
  Write-Host -ForegroundColor "DarkRed" -Object "Failed to Create Windows Installer COM Object"
}

#If ([System.IO.File]::Exists("$($ENV:TEMP)\$ExportFile"))
#{
#  [System.IO.File]::Delete("$($ENV:TEMP)\$ExportFile")
#}
#If ([System.IO.File]::Exists($WorkingMSI))
#{
#  [System.IO.File]::Delete($WorkingMSI)
#}
#If ([System.IO.File]::Exists($WorkingMST))
#{
#  [System.IO.File]::Delete($WorkingMST)
#}


