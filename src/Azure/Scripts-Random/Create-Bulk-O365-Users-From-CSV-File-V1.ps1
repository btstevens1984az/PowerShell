# Purpose: Create-Bulk O365 Users From CSV File — Microsoft Azure cloud resource management.


<#    


# Script      : Create-Bulk-O365-Users-From-CSV-File.ps1
# Author(s)   : Casey.Dedeal 
# Date        : 01/18/2020 14:18:44 
# Org         : ETC Solutions
# File Name   : Create-Bulk-O365-Users-From-CSV-File.ps1
# Comments    : Creating Bulk Azure AD users from CSV File
# Assumptions : Azure AD Tenant 

 
SYNOPSIS           : Create-Bulk-O365-Users-From-CSV-File.ps1
DESCRIPTION        : Create bulk Azure AD User Accounts
Acknowledgements   : Open license
Limitations        : None
Known issues       : None
Credits            : Please visit: 
                          https://simplepowershell.blogspot.com
                          https://msazure365.blogspot.com

# CSV HEADERS ( Make sure CSV file contains following headers)
UserPrincipalName,FirstName,LastName,DisplayName,UsageLocation,AccountSkuId

# CSV FILE DATA
UserPrincipalName : Test1@CloudSec365.onmicrosoft.com
FirstName         : Test1
LastName          : TEST-User1
DisplayName       : Test1
UsageLocation     : US

.EXAMPLE

  .\Create-Bulk-O365-Users-From-CSV-File.ps1

  MAP:

  -----------
  #(1).CSV Data Sample Headers
  #(2)_.Function Get CSV File
  #(3)_.Function-Get-Time Stamp 
  #(4)_.Function Create export folder
  #(5)_.Run Function to get CSV File /Import CSV
  #(6)_.Add Vars
  #(7)_.Function-Connect-Azure-PoWerShell 
  #(7.1)_.Validate if Azure PS exist 
  #(7.2)_.Connected -O365 Azure PowerShell Module
  #(7.3)_.Add Vars Modify $company Var for convenience
  #(7.4)_.Catch Errors
  #(8)_.Add more Vars/Count records
  #(9)_.Start Looping / Create Bulk users
  #(10)_.Diplay results CSV file

#>

 
#(1).CSV Data Sample Headers
<#


# CSV HEADERS

UserPrincipalName,FirstName,LastName,DisplayName,UsageLocation,AccountSkuId



# CSV FILE DATA

UserPrincipalName : Test1@CloudSec365.onmicrosoft.com
FirstName         : Test1
LastName          : TEST-User1
DisplayName       : Test1
UsageLocation     : US
AccountSkuId      : CloudSec365:O365_BUSINESS_PREMIUM


#>

#(2)_.Function Get CSV File
Function Function-Get-CSV ($FileRoot)
{  
 [System.Reflection.Assembly]::LoadWithPartialName(“System.windows.forms”) | Out-Null
 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = 'C:\temp'
 $OpenFileDialog.filter = “All files (*.*)| *.*”
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
 $FileRoot = 'C:\temp'
} 

#(3)_.Function-Get-Time Stamp 
function Function-Get-TimeStamp { 
  [CmdletBinding()]
  param()   
  return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)    
} 

#(4)_.Function Create export folder
function Function-Check-Folder 
{
  [CmdletBinding()]
   param() 
   $filepath = 'C:\temp\Reports\'
   If(!( test-path $filepath))
{
   New-Item -ItemType Directory -Force -Path $filepath | Out-Null
}}Function-Check-Folder

#(5)_.Run Function to get CSV File /Import CSV
$file    = Function-Get-CSV -initialDirectory $FileRoot
$CSVdata = Import-Csv -path $file

#(6)_.Add Vars
$now      = (Get-Date).tostring("dd-MM-yyyy-HH-MM-ss")
$filepath = 'C:\temp\Reports\'
$fname    = '_Results.CSV'
$outfile  = $filepath+$now+$fname
$Count    = ($CSVdata).count 

#(7)_.Function-Connect-Azure-PoWerShell 
function Function-Connect-Azure-PoWerShell  
{ 
  [CmdletBinding()]
  param()

Try{ 
 
 #(7.1)_.Validate if Azure PS exist 
 $session  = Get-MsolDomain -EA SilentlyContinue 
 if ($session) { 
    #(7.2)_.Connected -O365 Azure PowerShell Module 
    Write-Host 'ALREADY Connected: Azure PowerShell' 
   } else { 
    #(7.3)_.Add Vars Modify $company Var for convenience
     $company   = '@.OnMicrosoft.com' 
     $adminUser = "$env:USERNAME" 
     $UPN =  $adminUser + $company 
     Write-Host 'Connecting: Azure PowerShell' -f Gray -b DarkCyan 
     $cred  = Get-Credential -Credential $UPN -ErrorAction Stop 
     Connect-MsolService -Credential $cred -ErrorAction Stop | Out-Null 
          } 
}Catch{ 
 
 #(7.4)_.Catch Errors 
 Write-Host 'ERROR Occoured' -f DarkCyan
 Write-Host "ERROR:$($PSItem.ToString())" -f DarkCyan
 
}}Function-Connect-Azure-PoWerShell 

#(8)_.Add more Vars/Count records 
$total = ($CSVdata).count
$i = 1 
Write-host '++++++++++++++++++++++++++++++++++++' -f  DarkGreen 
write-host 'Creating <BULK> users'
write-host 'New User Count:'$total
Write-host '++++++++++++++++++++++++++++++++++++' -f DarkGreen 
write-host 'Report run: ' -NoNewline; Function-Get-TimeStamp
Read-host 'Press <ENTER> to Continue to Start creating users' 

#(9)_.Start Looping / Create Bulk users
foreach ($user in $CSVdata)
{
  Try{
  
   $UPN = $user.UserPrincipalName 
   write-Progress -activity "Processing  ($UPN)" -status "$i out of $total users scanned"
   write-host "($i)_.Creating User:" $UPN -f DarkYellow

     $newUser = New-MsolUser -DisplayName $user.DisplayName `
                      -FirstName $user.FirstName `
                      -LastName $user.LastName `
                      -UserPrincipalName $user.UserPrincipalName `
                      -UsageLocation $user.UsageLocation `
                      -LicenseAssignment $user.AccountSkuId -ErrorAction stop
     $newUser | Export-Csv -Path $outfile -NoTypeInformation -Append
     # Export CSV contains random passwrods for each user.

}Catch{

  Write-host 'ERROR FOUND:'
  Write-Host "ERROR: $($PSItem.ToString())"
  
 }$i++
}

#(10)_.Diplay results CSV file
read-host 'Press <ENTER> to open export file'
start $fileRoot
