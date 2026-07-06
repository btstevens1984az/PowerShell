Function Get-RemotePSInfo 
{ 
<# 
.Synopsis 
This function is used to call "Get-PSinfo" function either for a single computer or multiple computers 
.Description 
This script gets Powershell version,Winrm Service status and .net Versio information of a remote computer 
.PARAMETER Vminput 
Enter the VMname of which you need to find out vcenter servers 
.Inputs 
This Script can accept inputs via pipeline 
.Example 
Get-RemotePSInfo -computername 6.137.91.103 -OutputFilepath C:\temp\123.csv 
.Example 
Get-RemotePSInfo -InputFilepath C:\temp\computerlist.txt -OutputFilepath C:\temp\123.csv 
.Inputs 
Computername 
.Inputs 
InputFilepath 
.OUTPUTS 
None. 
 
#> 
#Requires -Version 4.0 
[cmdletbinding(DefaultParameterSetName="singleComputer")]param( 
       [parameter(Mandatory=$true, 
                  ValueFromPipeline=$true, 
                  Position=0, 
                  parametersetname='singleComputer') 
       ][string]$Computername, 
       [parameter(Mandatory=$true, 
                  ValueFromPipeline=$False, 
                  Position=0, 
                  parametersetname='Inputfromfile') 
       ][string]$InputFilepath=$null, 
       [parameter(Mandatory=$true, 
                  ValueFromPipeline=$true, 
                  Position=1 
                  ) 
       ][string]$OutputFilepath 
 
       ) 
if ($InputFilepath -eq "") 
        { 
        Write-host "Getting PSinfo for $Computername" -ForegroundColor Yellow 
        Get-PSInfo -computer $Computername | select @{l="COMName";e={$Computername}},PSVersion,ExecutionPolicy,WinRMStatus,NetFXVersion | export-csv $OutputFilepath -Append 
        Write-host " PSinfo for $Computername stored in $outputFilepath" -ForegroundColor Green 
        } 
else  
        { 
        $computerlist = Get-Content $InputFilepath 
        foreach ($computername in $computerlist) 
        { 
        Write-Host "Getting PSinfo for $Computername" -ForegroundColor Yellow 
        Get-PSInfo -computer $computername | select @{l="COMName";e={$computername}},PSVersion,ExecutionPolicy,WinRMStatus,NetFXVersion | export-csv $OutputFilepath -Append 
        } 
        Write-host " PSinfo for All Above computers stored in $outputFilepath" -ForegroundColor Green 
        } 
} 
 
 
function Get-PSInfo  
{ 
<# 
.Synopsis 
This script gets Powershell version,Winrm Service status and .net Versio information of a remote computer 
.Description 
This script gets Powershell version,Winrm Service status and .net Versio information of a remote computer 
.PARAMETER Computername 
Enter the computername of which you need to find out PS information details 
.Inputs 
This Script can accept inputs via pipeline 
.Example 
Get-PSInfo "Computername" 
.OUTPUTS 
None. 
#> 
#Requires -Version 4.0 
param ([parameter(Mandatory=$true, 
                  ValueFromPipeline=$true, 
                  Position=0)][string[]]$computer 
       ) 
$dotNetRegistry  = 'SOFTWARE\Microsoft\NET Framework Setup\NDP' 
$dotNet4Registry = 'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' 
$dotNet4Builds = @{ 
                    30319  =  '.NET Framework 4.0' 
                    378389 = '.NET Framework 4.5' 
                    378675 = '.NET Framework 4.5.1 (8.1/2012R2)' 
                    378758 = '.NET Framework 4.5.1 (8/7 SP1/Vista SP2)' 
                    379893 = '.NET Framework 4.5.2'  
                    393295 = '.NET Framework 4.6 (Windows 10)' 
                    393297 = '.NET Framework 4.6 (NON Windows 10)' 
                   } 
$RegKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $computer) 
        if ($regKey.OpenSubKey('SOFTWARE\\212.228.214.64\\NET Framework Setup\\79.249.89.72\\172.5.152.163\Client') ) 
        { 
            $netRegKey= $RegKey.OpenSubKey('SOFTWARE\\212.228.214.64\\NET Framework Setup\\79.249.89.72\\172.5.152.163\Client') 
            $netver = ($netRegKey.getvalue(“version”)).tostring() 
        } 
        elseif ($regKey.OpenSubKey('SOFTWARE\\212.228.214.64\\NET Framework Setup\\79.249.89.72\\v4.0\Client') ) 
        { 
            $netRegKey= $RegKey.OpenSubKey('SOFTWARE\\212.228.214.64\\NET Framework Setup\\79.249.89.72\\v4.0\Client') 
            $netver = ($netRegKey.getvalue(“version”)).tostring() 
        } 
        elseif ($regKey.OpenSubKey('SOFTWARE\\212.228.214.64\\NET Framework Setup\\79.249.89.72\\v3.5') ) 
        { 
            $netRegKey= $RegKey.OpenSubKey('SOFTWARE\\212.228.214.64\\NET Framework Setup\\79.249.89.72\\v3.5') 
            $netver = ($netRegKey.getvalue(“version”)).tostring() 
        } 
        elseif ($regKey.OpenSubKey('SOFTWARE\\212.228.214.64\\NET Framework Setup\\79.249.89.72\\v3.0') ) 
        { 
            $netRegKey= $RegKey.OpenSubKey('SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.0') 
            $netver = ($netRegKey.getvalue(“version”)).tostring() 
        } 
        elseif ($regKey.OpenSubKey('SOFTWARE\\212.228.214.64\\NET Framework Setup\\79.249.89.72\\v2.0.50727') ) 
        { 
            $netRegKey= $RegKey.OpenSubKey('SOFTWARE\\212.228.214.64\\NET Framework Setup\\79.249.89.72\\v2.0.50727') 
            $netver = ($netRegKey.getvalue(“version”)).tostring() 
        } 
 
if ($RegKey.OpenSubKey(“SOFTWARE\\212.228.214.64\\177.123.108.113\\3”))  
        { 
        $PSRegKey= $RegKey.OpenSubKey(“SOFTWARE\\212.228.214.64\\177.123.108.113\\28.241.164.132\\168.122.127.8\\Microsoft.PowerShell”) 
        $Policy = ($PSRegKey.getvalue(“ExecutionPolicy”)).tostring() 
        $PSRegKey1= $RegKey.OpenSubKey(“SOFTWARE\\212.228.214.64\\177.123.108.113\\132.205.184.150\\PowerShellEngine”) 
        $Version = ($PSRegKey1.getvalue(“PowerShellVersion”)).tostring() 
        $serviceStatus = Get-WmiObject -Class Win32_Service -Filter "name='WinRM'" -computername $computer |select State  
        #Return $Policy,$Version,$serviceStatus.state 
        $property = [ordered]@{ 
                              'Computername'=$computer; 
                              'PSVersion' = $Version; 
                              'ExecutionPolicy' = $Policy 
                              'WinRMStatus' = $serviceStatus.state 
                              'NetFXVersion' = $netver 
                               } 
        $x= New-Object -TypeName PSobject -Property $property 
        $x 
        } 
elseif ($RegKey.OpenSubKey(“SOFTWARE\\212.228.214.64\\177.123.108.113\\1”)) 
        { 
        $PSRegKey= $RegKey.OpenSubKey(“SOFTWARE\\212.228.214.64\\177.123.108.113\\28.241.164.132\\168.122.127.8\\Microsoft.PowerShell”) 
        $Policy = ($PSRegKey.getvalue(“ExecutionPolicy”)).tostring() 
        $PSRegKey1= $RegKey.OpenSubKey(“SOFTWARE\\212.228.214.64\\177.123.108.113\\28.241.164.132\\PowerShellEngine”) 
        $Version = ($PSRegKey1.getvalue(“PowerShellVersion”)).tostring() 
        $serviceStatus = Get-WmiObject -Class Win32_Service -Filter "name='WinRM'" -computername $computer |select State 
        #Return $Policy,$Version,$serviceStatus.state 
        $property = @{ 
                      'Computername'=$computer; 
                      'PSVersion' = $Version; 
                      'ExecutionPolicy' = $Policy 
                      'WinRMStatus' = $serviceStatus.state 
                      'NetFXVersion' = $netver 
                      } 
        $y = New-Object -TypeName PSobject -Property $property 
        $y 
        } 
else  
        { 
        $serviceStatus = Get-WmiObject -Class Win32_Service -Filter "name='WinRM'" -computername $computer |select State 
        $property = @{ 
                      'Computername'=$computer; 
                      'PSVersion' = "Not Installed" 
                      'ExecutionPolicy' = "Not Installed" 
                      'WinRMStatus' = $serviceStatus.state 
                      'NetFXVersion' =  $netver 
                      } 
        $z = New-Object -TypeName PSobject -Property $property 
        $z 
        } 
} 
 