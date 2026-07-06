# Purpose: Show-Menu — Windows Update and patch management.
function Show-Menu 
 
{ 
 
 
     param ( 
           [string]$Title = 'Welcome to the PatchMonitor V1.0 !' 
     ) 
     cls 
     Write-Host "=====$Title =====" 
     Write-Host "                   " 
      
     Write-Host "Using this script , you can get the details of patch installtion in multiple servers." 
     Write-Host "                   " 
     Write-Host "The script will capture Horfix numbers, Hotfix type, Date installed, Installed By and Uptime." 
     Write-Host "       " 
     Write-Host "It also captures all automatic services which are not running." 
     Write-Host "                   " 
     Write-Host "Test before you use in production. Use Powershell 4.0 or higher." 
     Write-Host "                   " 
     Write-Host "Use at your own Risk." 
 
     Write-Host "                   " 
 
     Write-Host "--------------MENU----------------" 
     Write-Host "                   " 
     Write-Host "1: Press 1 to get installed Patch details." 
     Write-Host "                   " 
     Write-Host "2: Press 2 to get stopped service details." 
     Write-Host "                   " 
     Write-Host "Q: Press 'Q' to quit this Program." 
     Write-Host "----------------------------------" 
     Write-Host "                   " 
 
} 
 
<# Beginning of the function GetPatchInfo  #> 
 
function GetPatchInfo 
 
{ 
Write-Host " " 
 
$inputpath= Read-Host "Please enter the location of the input file. It should be a text file."  
 
Write-Host " " 
 
$outputpath= Read-Host "Please enter the location of the output file. It should be a CSV file."  
 
Write-Host " " 
 
$range = Read-Host "Please enter the number of days (counting back from current date) for which you want patching details." 
 
$computerlist= get-content -Path $inputpath 
 
$date=Get-Date 
 
$date1= $date.ToString("MM/dd/yyyy") 
 
 
$olddate= (Get-date).AddDays(-$range) 
 
$olddate1= $olddate.ToString("MM/dd/yyyy") 
 
 
Write-Host " " 
Write-Host "This Script will show all patches installed on these Servers between $olddate1 and $date1, and will export the result to $outputpath" 
 
$Results= @() 
 
foreach ( $computername in $computerlist) 
 
{ 
 
   $wmi = Get-WmiObject -ComputerName $computername -Query "SELECT LastBootUpTime FROM Win32_OperatingSystem" 
   $now = Get-Date      
   $boottime = $wmi.ConvertToDateTime($wmi.LastBootUpTime) 
   
   $hotfixlist= Get-HotFix -ComputerName $computername | Where {$_.InstalledOn -ge $olddate} 
 
   foreach ($hotfix in $hotfixlist ) 
 
   { 
 
   $Properties =  @{ 
         
        ServerName= $computername 
        Description = $hotfix.Description 
        HotFixId= $hotfix.HotFixId 
        InstalledOn= $hotfix.InstalledOn 
        InstalledBy= $hotfix.InstalledBy 
        LastReboot= $boottime 
         
                    } 
 
   $Results+= New-Object psobject -Property $Properties | select-object ServerName,Description,HotFixId,InstalledOn,InstalledBy,LastReboot 
    
  }          
                 
} 
 
$Results |ft * 
 
$Results | Export-Csv -Path $outputpath -NoTypeInformation 
 
} 
 
<# End of the function GetPatchInfo #> 
 
<# Beginning of the function GetServiceStatus #> 
 
 
function GetServiceStatus 
 
{ 
 
Write-Host " " 
 
$inputpath= Read-Host "Please enter the location of the input file. It should be a text file."  
 
Write-Host " " 
 
$outputpath= Read-Host "Please enter the location of the output file. It should be a CSV file."  
 
Write-Host " " 
 
$computerlist= get-content -Path $inputpath 
 
foreach ($server in $serverlist) 
 
{ 
 
$result= Get-WMIobject -ComputerName $server win32_service -Filter "StartMode ='Auto' AND State != 'Running'" 
 
$result | Select-Object @{label='Server Name'; expression= {$server}},DisplayName,Name,StartMode,State | export-csv -Path $outputpath -NoTypeInformation -Append 
 
$result | Select-Object @{label='Server Name'; expression= {$server}},DisplayName,Name,StartMode,State |ft 
 
} 
 
} 
 
 
<# End of the function GetServiceStatus #> 
 
do 
{ 
Show-Menu 
 
$input = Read-Host "Please make a selection" 
 
 
switch ($input) 
     { 
           '1' { 
 
                cls 
 
                'You have selected option #1: Check Patch Details.' 
                 
                 Write-Host "                   " 
                  
                 GetPatchInfo 
 
 
                } 
 
  
            '2' { 
 
                cls 
 
                'You have selected option #2: Get Automatic Service Details which are in stopped state.' 
 
                 Write-Host "                   " 
                 
                 GetServiceStatus 
 
 
                } 
 
                              
             'q' { 
 
                return 
                 } 
     }  
     pause 
} 
until ($input -eq 'q') 