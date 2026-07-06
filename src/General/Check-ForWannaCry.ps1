# Purpose: Check-ForWannaCry — General-purpose PowerShell utilities.
# This function manually checks if your machine has any of the hotfixes listed already installed.
# It is only called if we cannot verify by checking the %systemroot%\system32\drivers\srv.sys file version.
Function Check-ForWannaCry
{
  # Reference: https://community.spiceworks.com/topic/1994651-check-for-missing-wannacry-patches-with-powershell

  # List of patches that remediate WannaCry
  $patches = "KB4041693", "KB4041690", "KB4013429", "KB4012606", "KB4013198", "KB4018466", "KB4012598", "KB4012212", "KB4012215", "KB4012213", "KB4012216", "KB4012214", "KB4012217", "KB4016871", "KB4019472", "KB4019213", "KB4019217", "KB4019264", "KB4022715", "KB4022726", "KB4022719", "KB4025341", "KB4034664", "KB4038777", "KB4041681", "KB4025336", "KB4034681", "KB4038792", "KB4041693", "KB4025331", "KB4015548", "KB4019214", "KB4022718", "KB4025343", "KB4034666", "KB4038786", "KB4041679", "KB4015550", "KB4019215", "KB4016637", "KB4015221", "KB4019474", "KB4015549", "KB4019263", "KB4019216", "KB4015551", "KB4015554", "KB4012220", "KB4016636", "KB4015219", "KB4019473", "KB4015217", "KB4016635", "KB4019265", "KB4022722", "KB4022168", "KB4019218", "KB4022724", "KB4022717", "KB4022720", "KB4032695", "KB4032693", "KB4022723"
  $computer = $ENV:COMPUTERNAME

  # Define a new array to gather output
  $UpdateCollection= @()

  # From https://bogner.sh/2017/05/how-to-check-if-ms17-010-has-already-been-installed/
  #
  # Windows 2008's Get-HotFix may not display all installed HotFixes, so a second method is required
  # to collect installed HotFixes

  if ($wu = New-Object -ComObject Microsoft.Update.Searcher)
  {
    $totalupdates = $wu.GetTotalHistoryCount()
    if ($totalupdates -ne 0) {
      $all = $wu.QueryHistory(0,$totalupdates)
    }

    Foreach ($update in $all)
    {
      $string = $update.title

      $Regex = "KB\d*"
      $KB = $string | Select-String -Pattern $regex | Select-Object { $_.Matches }

      $output = New-Object -TypeName PSobject
      $output | add-member NoteProperty "HotFixID" -value $KB.' $_.Matches '.Value
      $output | add-member NoteProperty "Title" -value $string
      $UpdateCollection += $output
    }
  }

  # Retrieve a list of Hotfixes already installed
  $hotfixList = Get-HotFix

  if ($hotfixList)
  {
    Foreach ($hotfix in $hotfixList) {
      $output = New-Object -TypeName PSobject
      $output | add-member NoteProperty "HotFixID" -value $hotfix.HotFixID
      $output | add-member NoteProperty "Title" -value $hotfix.Description
      $UpdateCollection += $output
    }

    # Detect if any of the patches are updated already
    $patch = $UpdateCollection |
      Where-Object {$patches -contains $_.HotfixID} |
      Select-Object -property "HotFixID"
  }

  # Output vulnerability fact about this machine
  if($patch) {
    $vulnerability = "wannacry_vulnerable=false"
  } else {
    $vulnerability = "wannacry_vulnerable=true"
  }

  Write-Host $vulnerability
}

# Reference: https://support.microsoft.com/en-us/help/4023262/how-to-verify-that-ms17-010-is-installed
# Compare the file version of %systemroot%\system32\drivers\srv.sys to a version that is not vulnerable from MSFT.
# If srv.sys check isn't available, switch to manually checking for installed hotfixes with Check-ForWannaCry function.
[reflection.assembly]::LoadWithPartialName("System.Version")
$os = Get-WmiObject -class Win32_OperatingSystem
$osName = $os.Caption
$s = "%systemroot%\system32\drivers\srv.sys"
$v = [System.Environment]::ExpandEnvironmentVariables($s)
$vulnerability = $null

If (Test-Path "$v")
{
  Try
  {
    $versionInfo = (Get-Item $v).VersionInfo
    $versionString = "$($versionInfo.FileMajorPart).$($versionInfo.FileMinorPart).$($versionInfo.FileBuildPart).$($versionInfo.FilePrivatePart)"
    $fileVersion = New-Object System.Version($versionString)
  }
  Catch
  {
    # Unable to retrieve file version info, verifying vulnerability state manually.
    Check-ForWannaCry
    Break
  }
}
Else
{
  # Srv.sys does not exist, verifying vulnerability state manually.
  Check-ForWannaCry
  Break
}
if ($osName.Contains("Vista") -or ($osName.Contains("2008") -and -not $osName.Contains("R2")))
{
  if ($versionString.Split('.')[3][0] -eq "1")
  {
    $currentOS = "$osName GDR"
    $expectedVersion = New-Object System.Version("6.0.6002.19743")
  }
  elseif ($versionString.Split('.')[3][0] -eq "2")
  {
    $currentOS = "$osName LDR"
    $expectedVersion = New-Object System.Version("6.0.6002.24067")
  }
  else
  {
    $currentOS = "$osName"
    $expectedVersion = New-Object System.Version("9.9.9999.99999")
  }
}
elseif ($osName.Contains("Windows 7") -or ($osName.Contains("2008 R2")))
{
  $currentOS = "$osName LDR"
  $expectedVersion = New-Object System.Version("6.1.7601.23689")
}
elseif ($osName.Contains("Windows 8.1") -or $osName.Contains("2012 R2"))
{
  $currentOS = "$osName LDR"
  $expectedVersion = New-Object System.Version("6.3.9600.18604")
}
elseif ($osName.Contains("Windows 8") -or $osName.Contains("2012"))
{
  $currentOS = "$osName LDR"
  $expectedVersion = New-Object System.Version("6.2.9200.22099")
}
elseif ($osName.Contains("Windows 10"))
{
  if ($os.BuildNumber -eq "10240")
  {
    $currentOS = "$osName TH1"
    $expectedVersion = New-Object System.Version("10.0.10240.17319")
  }
  elseif ($os.BuildNumber -eq "10586")
  {
    $currentOS = "$osName TH2"
    $expectedVersion = New-Object System.Version("10.0.10586.839")
  }
  elseif ($os.BuildNumber -eq "14393")
  {
    $currentOS = "$($osName) RS1"
    $expectedVersion = New-Object System.Version("10.0.14393.953")
  }
  elseif ($os.BuildNumber -eq "15063")
  {
    $currentOS = "$osName RS2"
    "No need to Patch. RS2 is released as patched."
    return
  }
}
elseif ($osName.Contains("2016"))
{
  $currentOS = "$osName"
  $expectedVersion = New-Object System.Version("10.0.14393.953")
}
elseif ($osName.Contains("Windows XP"))
{
  $currentOS = "$osName"
  $expectedVersion = New-Object System.Version("5.1.2600.7208")
}
elseif ($osName.Contains("Server 2003"))
{
  $currentOS = "$osName"
  $expectedVersion = New-Object System.Version("5.2.3790.6021")
}
else
{
  # Unable to determine OS applicability, verifying vulnerability state manually.
  Check-ForWannaCry
  Break
}
If ($($fileVersion.CompareTo($expectedVersion)) -lt 0)
{
  $vulnerability = "wannacry_vulnerable=true"
}
Else
{
  $vulnerability = "wannacry_vulnerable=false"
}

# Srv.sys check finished, print vulnerabiliy state
Write-Host $vulnerability
