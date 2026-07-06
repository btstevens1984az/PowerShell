Function Get-OfficeVersion {
<#
.Synopsis
   Get-OfficeVersion 
.DESCRIPTION
   Gets the Office version from a list of computernames and returns a CSV of the Computername and Office Version (if available)
.EXAMPLE
 Get-OfficeVersion 'c:\Users\$env:USERNAME\Desktop\OfficeCheck.txt' 'c:\Users\$env:USERNAME\Desktop\officeversions.csv'
.EXAMPLE
 get-officeversion -infile c:\test\servers.txt -outfile c:\test\officeversions.csv
   General notes
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $Infile,
    [Parameter(Mandatory=$true)]
    [string] $outfile
    )
#$outfile = 'C:\temp\office.csv'
#$infile = 'c:\temp\servers.txt'
Begin
    {
    }
 Process
    {
    $office = @()
    $computers = Get-Content $infile
    $i=0
    $count = $computers.count
    foreach($computer in $computers)
     {
     $i++
     Write-Progress -Activity "Querying Computers" -Status "Computer: $i of $count " `
      -PercentComplete ($i/$count*100)
        $info = @{}
        $version = 0
        try{
          $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computer) 
          $reg.OpenSubKey('software\Microsoft\Office').GetSubKeyNames() |% {
            if ($_ -match '(\d+)\.') {
              if ([int]$matches[1] -gt $version) {
                $version = $matches[1]
              }
            }    
          }
          if ($version) {
            Write-Debug("$computer : found $version")
            switch($version) {
                "7" {$officename = 'Office 97' }
                "8" {$officename = 'Office 98' }
                "9" {$officename = 'Office 2000' }
                "10" {$officename = 'Office XP' }
                "11" {$officename = 'Office 97' }
                "12" {$officename = 'Office 2003' }
                "13" {$officename = 'Office 2007' }
                "14" {$officename = 'Office 2010' }
                "15" {$officename = 'Office 2013' }
                "16" {$officename = 'Office 2016' }
                default {$officename = 'Unknown Version'}
            }
    
          }
          }
          catch{
              $officename = 'Not Installed/Not Available'
          }
    $info.Computer = $computer
    $info.Name= $officename
    $info.version =  $version

    $object = new-object -TypeName PSObject -Property $info
    $office += $object
    }
    $office | select computer,version,name | Export-Csv -NoTypeInformation -Path $outfile
    }
}
  write-output ("Done")
  }